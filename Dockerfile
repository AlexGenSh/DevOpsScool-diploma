FROM python:3.10.4-slim-buster
EXPOSE 5000/tcp
WORKDIR /app
COPY requirements.txt requirements.txt
RUN apt install default-libmysqlclient-dev
RUN pip3 install -r requirements.txt
COPY . .
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
