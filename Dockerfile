FROM python:3.10.4-buster
ARG VAR1
ARG VAR2
ARG VAR3
ENV DB_ADMIN_USERNAME=$VAR1
ENV DB_ADMIN_PASSWORD=$VAR2
ENV DB_URL=$VAR3
EXPOSE 8080/tcp
WORKDIR /app/
COPY requirements.txt requirements.txt
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
