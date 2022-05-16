import os

from flask_wtf.csrf import CSRFProtect
from flask import Flask, render_template, redirect, request
from sqlalchemy import create_engine, Column, String, Integer
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from urllib.request import urlopen
from json import loads


app = Flask(__name__)
csrf = CSRFProtect()
csrf.init_app(app)


def func_parse_json(json_data):
    # Function takes as input data received via API for all planets, parses and puts it into a list

    summary_get_json = []
    var_name = json_data['name']
    var_rotation_period = json_data['rotation_period']
    var_orbital_period = json_data['orbital_period']
    var_diameter = json_data['diameter']
    var_climate = json_data['climate']
    var_gravity = json_data['gravity']
    var_terrain = json_data['terrain']
    var_surface_water = json_data['surface_water']
    var_population = json_data['population']
    var_url = json_data['url']

    list1 = [
        var_name,
        var_rotation_period,
        var_orbital_period,
        var_diameter,
        var_climate,
        var_gravity,
        var_terrain,
        var_surface_water,
        var_population,
        var_url
    ]

    summary_get_json.append(list1)
    return summary_get_json


def func_parse_json_p(json_people):
    # Function takes as input data received via API for all peoples, parses and puts it into a list
    summary_get_json_p = []
    var_name = json_people['name']
    var_height = json_people['height']
    var_mass = json_people['mass']
    var_hair_color = json_people['hair_color']
    var_skin_color = json_people['skin_color']
    var_eye_color = json_people['eye_color']
    var_birth_year = json_people['birth_year']
    var_gender = json_people['gender']
    var_homeworld = json_people['homeworld']

    list1 = [
        var_name,
        var_height,
        var_mass,
        var_hair_color,
        var_skin_color,
        var_eye_color,
        var_birth_year,
        var_gender,
        var_homeworld
    ]

    summary_get_json_p.append(list1)
    return summary_get_json_p


def func_insert_db(summary_get_json):
    # Function to insert records into planets database
    for j in summary_get_json:
        x = Planet(name=j[0], rotation_period=j[1], orbital_period=j[2], diameter=j[3], climate=j[4], gravity=j[5],
                   terrain=j[6], surface_water=j[7], population=j[8], url=j[9])
        session.add(x)
        session.commit()


def func_insert_db_p(summary_get_json_p):
    # Function to insert records into peoples database
    for j in summary_get_json_p:
        x = People(name=j[0], height=j[1], mass=j[2], hair_color=j[3], skin_color=j[4], eye_color=j[5],
                   birth_year=j[6], gender=j[7], homeworld=j[8])
        session.add(x)
        session.commit()


def func_populate_or_update_db(var_planet):
    global json_data
    while var_planet <= 60:

        url_planet = url_api + 'planets/' + str(var_planet) + '/'
        try:
            response = urlopen(url_planet)
            json_data = loads(response.read())
        except Exception:
            print(json_data)
            var_planet = var_planet + 1
            continue
        # Call function "func_insert_db" to insert into DB parsed data that was obtained via API
        func_insert_db(func_parse_json(json_data))
        var_planet = var_planet + 1
    return None


def func_update_peoples_db(var_people):
    global json_people
    while var_people <= 82:
        url_people = url_api + 'people/' + str(var_people) + '/'
        try:
            response = urlopen(url_people)
            json_people = loads(response.read())
        except Exception:
            var_people = var_people + 1
            continue
        # Call function "func_insert_db" to insert into DB parsed data that was obtained via API
        func_insert_db_p(func_parse_json_p(json_people))
        var_people = var_people + 1
    return None


url_api = 'https://swapi.dev/api/'

#engine = create_engine('mysql+mysqldb://root:vagrant@192.168.56.115/mydb')
#engine = create_engine('mysql+mysqldb://' + os.environ.get('DB_ADMIN_USERNAME') + ':'+os.environ.get('DB_ADMIN_PASSWORD')+"@"+os.environ.get('DB_URL'))

#engine = create_engine('mysql+mysqldb://' + str(os.environ.get('VAR1')) + ':' + str(os.environ.get('VAR2')) + '@' + str(os.environ.get('VAR3')))
url_engine = "mysql+mysqldb://" + str(os.environ.get('DB_ADMIN_USERNAME')) + ":" + str(os.environ.get('DB_ADMIN_PASSWORD')) + "@" + str(os.environ.get('DB_URL'))
engine = create_engine(url_engine)

# engine = create_engine("postgresql://" + os.environ.get('DB_ADMIN_USERNAME') + ":"+os.environ.get('DB_ADMIN_PASSWORD')+"@"+os.environ.get('DB_URL_POSTGRES')+"")
# Connecting to the database "mydb"; the database itself should already exist, the app will not
# create database itself. But the app will create tables in the database if they do not exist.


Base = declarative_base()


# Creating a declarative base class that stores a catalog of classes and mapped tables in the Declarative system


class Planet(Base):
    __tablename__ = 'planets'  # Actual name of the table in the database
    id = Column(Integer, primary_key=True)
    name = Column(String(300))
    rotation_period = Column(String(150))
    orbital_period = Column(String(150))
    diameter = Column(String(150))
    climate = Column(String(150))
    gravity = Column(String(150))
    terrain = Column(String(150))
    surface_water = Column(String(150))
    population = Column(String(150))
    url = Column(String(600))


class People(Base):
    __tablename__ = 'peoples'  # Actual name of the table in the database
    id = Column(Integer, primary_key=True)
    name = Column(String(300))
    height = Column(String(20))
    mass = Column(String(20))
    hair_color = Column(String(50))
    skin_color = Column(String(150))
    eye_color = Column(String(150))
    birth_year = Column(String(150))
    gender = Column(String(150))
    homeworld = Column(String(150))


Base.metadata.create_all(engine)  # Creating table in the database
Session = sessionmaker(engine)  # Defining a special Session class
session = Session()  # Creating an object of Session class


@app.route('/')
@app.route('/home')
def index():
    return render_template('index.html')


@app.route('/planet/<planet_name>/')
def planet_detail(planet_name):
    people_detail = []
    planet_detail_read_db = []
    search_planet = ''
    for i in session.query(Planet).filter(Planet.name == planet_name):
        list1 = [i.name,
                 i.rotation_period,
                 i.orbital_period,
                 i.diameter,
                 i.climate,
                 i.gravity,
                 i.terrain,
                 i.surface_water,
                 i.population,
                 i.url
                 ]
        planet_detail_read_db.append(list1)
        search_planet = list1[9]
        session.close()
        engine.dispose()
    for j in session.query(People).filter(People.homeworld == search_planet):
        list2 = [j.name,
                 j.height,
                 j.mass,
                 j.hair_color,
                 j.skin_color,
                 j.eye_color,
                 j.birth_year,
                 j.gender,
                 j.homeworld,
                 ]
        people_detail.append(list2)
        session.close()
        engine.dispose()
    return render_template('planet_detail.html', planet_detail_read_db=planet_detail_read_db,
                           people_detail=people_detail)


@app.route('/update')
def data_update():
    func_populate_or_update_db(1)
    func_update_peoples_db(1)
    session.close()
    engine.dispose()
    return redirect(request.referrer)


if __name__ == "__main__":
    app.run(host="0.0.0.0")
