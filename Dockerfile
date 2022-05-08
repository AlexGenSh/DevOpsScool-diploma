FROM python:3.10.4-buster
EXPOSE 5000/tcp
WORKDIR /app/
COPY requirements.txt requirements.txt
# RUN apt update
# RUN apt install python-dev
# RUN apt install python-MySQLdb
# RUN pip3 install MySQL-Python
# RUN apt-get install python3-dev libmysqlclient-dev
# RUN apt-get install python3-dev default-libmysqlclient-dev build-essentia
# RUN pip3 install wheel
RUN pip3 install -r requirements.txt
COPY ./app /app/
CMD [ "python3", "-m" , "flask", "run", "--host=0.0.0.0"]

# Environmental variables are inserted to the container via k8s and are not provided neither in Dockerfile nor in GitHub Actions
# Otherwise they have to be specified in Dockerfile and inserted during image build:
# ARG VAR1
# ENV DB_ADMIN_USERNAME=$VAR1
#
# docker build -t TAG --build-arg VAR1=$DB_ADMIN_USERNAME --build-arg VAR2=$DB_ADMIN_PASSWORD --build-arg VAR3=$DB_URL
#
# or (for GitHub Actions)
# build-args: |
#   VAR1=${{ secrets.DB_ADMIN_USERNAME }}
