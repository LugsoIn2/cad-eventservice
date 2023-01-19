from django.shortcuts import render
from django.http import JsonResponse
from rest_framework.views import APIView
from rest_framework.parsers import MultiPartParser, FormParser
from rest_framework.response import Response
from rest_framework import status
from rest_framework import generics, filters
from django.http import JsonResponse
from datetime import datetime
import boto3
from boto3.dynamodb.conditions import Attr
from django.conf import settings

# Dynamodb configuration
dynamodb = boto3.resource(
    'dynamodb',
    aws_access_key_id=settings.AWS_ACCESS_KEY,
    aws_secret_access_key=settings.AWS_SECRET,
    region_name='eu-central-1')


# Get All Files
def list(request):
    city = request.GET.get('city')
    date =  request.GET.get('date')
    table = dynamodb.Table(settings.EV_TABLE_NAME)
    filter = None
    if city and date:
        filter=Attr("city").eq(city) & Attr("eventDate").begins_with(date)
    elif city:
        filter=Attr("city").eq(city)
    elif date:
        filter=Attr("eventDate").begins_with(date)

    if filter:
        response = table.scan(FilterExpression=filter)
    else:
        response = table.scan()

    if response['ResponseMetadata']['HTTPStatusCode'] == 200:
        try:
            items = response['Items']
        except KeyError as e:
            print('Something went wrong')
        return JsonResponse(items, safe=False)
