"""webchat URL Configuration

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/1.8/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  url(r'^$', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  url(r'^$', Home.as_view(), name='home')
Including another URLconf
    1. Add a URL to urlpatterns:  url(r'^blog/', include('blog.urls'))
"""
from django.conf.urls import include, url
from django.views import generic, static
from django.contrib import admin
from django.conf import settings
from chatapp import wsviews

#from django.conf.urls.static import static
import os
import sys

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

urlpatterns = [
    url(r'^media/(.*)$', static.serve, kwargs={'document_root': '%s' %settings.MEDIA_ROOT}),
    url(r'^chat/',  include('chatapp.urls')),                          # chatapp
    url(r'^admin/', admin.site.urls),
    url(r'^api/message/(?P<source>\d+)/?$', wsviews.SaveMessage.as_view(),name='api_message'),
    url(r'^api/message/download/(?P<source>\d+)/?$', wsviews.DownloadMessage.as_view(),name='api_message_download'),
    url(r'^api/message/confirm/(?P<source>\d+)/?$', wsviews.ConfirmMessage.as_view(),name='api_message_confirm'),
    url(r'^api/validate/?$', wsviews.ValidateView.as_view(),name='api_validate'),
    url(r'^static/(.*)$', static.serve, kwargs={'document_root': '%s/static' %BASE_DIR}),
]
