import Debug "mo:base/Debug";
import Blob "mo:base/Blob";
import Bool "mo:base/Bool";
import Buffer "mo:base/Buffer";
import Cycles "mo:base/ExperimentalCycles";
import Error "mo:base/Error";
import Array "mo:base/Array";
import Nat8 "mo:base/Nat8";
import Nat "mo:base/Nat";
import Nat64 "mo:base/Nat64";
import Text "mo:base/Text";
import Timer "mo:base/Timer";

//import the custom types we have in Types.mo
import Types "Types";

actor {

  var url : Text = "";
  var host : Text = "";

  public func setUrl(newUrl : Text) : async Text {
    url := newUrl;
    return url;
  };

  public func setHost(newHost : Text) : async Text {
    host := newHost;
    return host;
  };

  public query func getUrl() : async Text {
    return url;
  };

  public query func getHost() : async Text {
    return host;
  };

  // function to transform the response
  public query func transform(raw : Types.TransformArgs) : async Types.CanisterHttpResponsePayload {
    let transformed : Types.CanisterHttpResponsePayload = {
      status = raw.response.status;
      body = raw.response.body;
      headers = [
        {
          name = "Content-Security-Policy";
          value = "default-src 'self'";
        },
        { name = "Referrer-Policy"; value = "strict-origin" },
        { name = "Permissions-Policy"; value = "geolocation=(self)" },
        {
          name = "Strict-Transport-Security";
          value = "max-age=63072000";
        },
        { name = "X-Frame-Options"; value = "DENY" },
        { name = "X-Content-Type-Options"; value = "nosniff" },
      ];
    };
    transformed;
  };

  public func ping() : async Text {
    let ic : Types.IC = actor ("aaaaa-aa");

    // 2.1 Setup the URL and its query parameters
    Debug.print("URL: " # url);

    // 2.2 prepare headers for the system http_request call
    let request_headers = [
      { name = "Host"; value = host },
      { name = "User-Agent"; value = "icping" },
    ];

    let transform_context : Types.TransformContext = {
      function = transform;
      context = Blob.fromArray([]);
    };

    // 2.3 The HTTP request
    let http_request : Types.HttpRequestArgs = {
      url = url;
      max_response_bytes = null;
      headers = request_headers;
      body = null;
      method = #get;
      transform = ?transform_context;
    };

    //3. ADD CYCLES TO PAY FOR HTTP REQUEST

    //The IC specification spec says, "Cycles to pay for the call must be explicitly transferred with the call"
    //IC management canister will make the HTTP request so it needs cycles
    //See: https://internetcomputer.org/docs/current/motoko/main/cycles

    //The way Cycles.add() works is that it adds those cycles to the next asynchronous call
    //"Function add(amount) indicates the additional amount of cycles to be transferred in the next remote call"
    //See: https://internetcomputer.org/docs/current/references/ic-interface-spec/#ic-http_request
    Cycles.add(230_949_972_000);

    //4. MAKE HTTPS REQUEST AND WAIT FOR RESPONSE
    //Since the cycles were added above, we can just call the IC management canister with HTTPS outcalls below
    let http_response : Types.HttpResponsePayload = await ic.http_request(http_request);

    Debug.print("Status code: " # Nat.toText(http_response.status));

    //5. DECODE THE RESPONSE

    let response_body : Blob = Blob.fromArray(http_response.body);
    let decoded_text : Text = switch (Text.decodeUtf8(response_body)) {
      case (null) { "No value returned" };
      case (?y) { y };
    };

    decoded_text;
  };

  // function to call repeatedly every `sec` seconds
  private func rep() : async () {
    if (url == "") {
      Debug.print("No URL is set");
    } else {

      try {

        let response : Text = await ping();
        if (response == "No value returned") {
          buffer.add(false);
        } else {
          buffer.add(true);
        };
      } catch _ {
        buffer.add(false);
      };

      // keep only the latest `size` of values
      if (buffer.size() > size) {
        ignore buffer.remove(0);
      };
    };
  };

  let size : Nat = 20;
  let buffer = Buffer.Buffer<Bool>(5);

  public query func getUptime() : async [Bool] {
    return Buffer.toArray(buffer);
  };

  let interval : Nat = 5;

  public query func getInterval() : async Nat {
    return interval;
  };

  ignore Timer.recurringTimer<system>(#seconds interval, rep);

};
