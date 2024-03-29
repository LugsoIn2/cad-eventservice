FROM python:3.9
#Docker doesn't buffer the output and that you can see the output 
#of the app in real-time.
ENV PYTHONUNBUFFERED 1

#setup gunicorn
RUN pip install gunicorn

# setup nginx
RUN apt-get update
RUN apt-get install -y nginx
COPY ./nginx/proxy-eventservice.conf /etc/nginx/sites-available/
RUN ln -s /etc/nginx/sites-available/proxy-eventservice.conf /etc/nginx/sites-enabled/proxy-eventservice.conf
RUN rm /etc/nginx/sites-enabled/default

# copy service source
RUN mkdir /eventservice
WORKDIR /eventservice
COPY ./eventservice .
COPY ./requirements.txt /eventservice/requirements.txt
RUN pip install -r /eventservice/requirements.txt

# collect all static files
RUN python /eventservice/manage.py migrate
RUN python /eventservice/manage.py collectstatic --noinput

WORKDIR /eventservice
EXPOSE 80

# run nginx + gunicorn
CMD (gunicorn --bind 127.0.0.1:8000 --user www-data --workers=2 eventservice.wsgi) & \
nginx -g "daemon off;"