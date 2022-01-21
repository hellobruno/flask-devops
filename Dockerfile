# Createsan image for python alpine image.(https://hub.docker.com/r/library/python/)
FROM python:3

# Copies the requirements.txt for Docker caching
COPY ./requirements.txt /app/requirements.txt

# WORKDIR is nothing but current directory (cd app)
WORKDIR /app

# Installs the requirements in the current directory
RUN pip install -r requirements.txt

# Copies the entire app to docker container in the app directory
COPY . /app

# Setsenvironmental path to app directory. Path environment vars tells shell which directories to search for executables
ENV PATH /app:$PATH

# Exposes port 5000 for binding
EXPOSE 5000

# Executes the command python app.py in the app directory.
CMD [ "python","app.py" ]