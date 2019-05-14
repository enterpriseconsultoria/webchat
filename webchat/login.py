#from django.conf import settings
#from django.http import HttpResponseRedirect, HttpResponse
#from django.shortcuts import render_to_response
#from django.contrib.auth import logout
#from django.utils.deprecation import MiddlewareMixin
#
#import re
#
#class RequireLoginMiddleware(MiddlewareMixin):
#    def __init__(self):
#        self.urls = tuple([re.compile(url) for url in settings.LOGIN_REQUIRED_URLS])
#    
#    def process_request(self, request):
#        for url in self.urls:
#            if url.match(request.path) and (request.user.is_anonymous() or not request.user.is_staff):
#                if not request.is_ajax():
#                    return HttpResponseRedirect('%s?next=%s' % (settings.LOGIN_URL, "/chat/master/"))
#                else:
#                    return render_to_response('401.html',{
#                                               'LOGINURL': settings.LOGIN_URL
#                                               })
#
#

from django.conf import settings
from django.http import HttpResponseRedirect, HttpResponse
from django.shortcuts import render_to_response
from django.contrib.auth import logout
from django.utils.deprecation import MiddlewareMixin

import re

class RequireLoginMiddleware(MiddlewareMixin):   
    def process_request(self, request):
        urls = tuple([re.compile(url) for url in settings.LOGIN_REQUIRED_URLS])
        for url in urls:
            if url.match(request.path) and (request.user.is_anonymous or not request.user.is_staff):
                if not request.is_ajax():
                    return HttpResponseRedirect('%s?next=%s' % (settings.LOGIN_URL, request.path))
                else:
                    return render_to_response('401.html',{
                                               'LOGINURL': settings.LOGIN_URL
                                               })

