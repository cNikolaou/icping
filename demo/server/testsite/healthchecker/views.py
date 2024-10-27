import time

from django.http import JsonResponse

# Create your views here.
def index(request):
    return JsonResponse({"status": str(time.time())})
