FROM python:3.10
#Docker doesn't buffer the output and that you can see the output 
#of the app in real-time.
ENV PYTHONUNBUFFERED 1
RUN mkdir /eventservice
WORKDIR /eventservice
COPY ./eventservice .
COPY ./requirements.txt /requirements.txt
RUN pip install -r /requirements.txt
RUN pip install gunicorn
WORKDIR /eventservice/eventservice
RUN adduser events_user
USER events_user