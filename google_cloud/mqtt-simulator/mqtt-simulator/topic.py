import time
import json
import random
import threading
from abc import ABC, abstractmethod
import paho.mqtt.client as mqtt
from expression_evaluator import ExpressionEvaluator
import datetime
import pandas as pd
import os
import shutil

class Topic(ABC):
    def __init__(self, broker_url, broker_port, topic_url, topic_data):
        self.broker_url = broker_url
        self.broker_port = broker_port
        self.topic_url = topic_url
        self.topic_data = topic_data
        self.client = None
        self.header = ['dateHour', 'gpsSpeed', 'gpsSatCount', 'Gear', 'Brake_pedal', 'Accel_pedal', 'Machine_Speed_Mesured', 'AST_Direction', 'Ast_HPMB1_Pressure_bar', 'Ast_HPMA_Pressure_bar', 'Pressure_HighPressureReturn', 'Pressure_HighPressure', 'Oil_Temperature', 'Ast_FrontAxleSpeed_Rpm', 'Pump_Speed', 'clienID', 'lat', 'long']
        self.image_path = '../images/data/export/'
        self.images_files = os.listdir(self.image_path)

    def connect(self):
        self.client = mqtt.Client(self.topic_url, clean_session=True, transport='tcp')
        self.client.on_publish = self.on_publish
        self.client.connect(self.broker_url, self.broker_port) 
        self.client.loop_start()

    @abstractmethod
    def run(self):
        pass

    def disconnect(self):
        self.client.loop_end()
        self.client.disconnect()

    def on_publish(self, client, userdata, result):
        # print(f'[{time.strftime("%H:%M:%S")}] Data published on: {self.topic_url}')
        pass


class TopicAuto(Topic, threading.Thread):
    def __init__(self, broker_url, broker_port, topic_url, topic_data, time_interval, save_path, client_id):
        Topic.__init__(self, broker_url, broker_port, topic_url, topic_data)
        threading.Thread.__init__(self, args = (), kwargs = None)
        self.time_interval = time_interval
        self.old_payload = None
        self.expression_evaluators = {}
        self.save_path = save_path
        self.client_id = client_id
        self.random_lat_long = [[(48.701947, 2.286114), (48.823289, 2.325151)], [(48.884486, 2.261907), (48.854231, 2.500003)], 
                                [(48.852228, 2.266303), (48.850225, 2.420863)], [(48.722608, 1.324794), (48.743230, 1.399017)], 
                                [(48.628842, 1.801536), (48.654451, 1.849417)], [(48.763697, 1.930696), (48.796989, 1.987133)], 
                                [(43.297425, 5.381862), (43.519414, 5.450519)], [(43.717723, 7.254764), (43.759121, 7.327194)], 
                                [(43.574852, 1.405824), (43.657831, 1.488358)], [(47.170253, -1.543241), (47.263073, -1.559000)]]

    def run(self):
        self.connect()
        buffer = []
        gps_index = int(str(self.client_id[-1]))
        (lat_b, long_b), (lat_e, long_e) = self.random_lat_long[gps_index]
        del_lat = (lat_e - lat_b)/36000
        del_long = (long_e - long_b)/36000
        index = 0
        while True:
            payload = self.generate_payload()
            payload['dateHour'] = str(datetime.datetime.now())
            payload['clienID'] = str(self.client_id)
            lat = lat_b + index*del_lat
            long = long_b + index*del_long
            index += 1
            payload['lat'] = lat
            payload['long'] = long
            self.old_payload = payload
            buffer.append(payload)
            
            # print(json.dumps(payload))
            # print(self.topic_url)
            self.client.publish(topic=self.topic_url, payload=json.dumps(payload), qos=2, retain=False)
            mes = {"lat": lat,
                   "lon": long,
                   "id": self.client_id,
                   "color": "Red"
                }
            self.client.publish(topic=f"cars/gps", payload=json.dumps(mes), qos=2, retain=False) 
            if len(buffer) == 90:
                file_name = 'csv/' + self.client_id + "_" + datetime.datetime.now().strftime("%Y-%m-%dT%H-%M-%S.%fZ")+ ".csv"
                file_name = os.path.join(self.save_path, file_name)
                pd.DataFrame(buffer, columns=self.header).to_csv(file_name, sep=";", index=False)
                buffer = []

            #save image
            if (index % 100) == 0:
                file_image_name = 'images/'+ 'X46789_1' + "_" + datetime.datetime.now().strftime("%Y-%m-%dT%H-%M-%S.%fZ") + ".jpeg"
                dst = os.path.join(self.save_path, file_image_name)
                src = self.image_path + random.choice(self.images_files)
                shutil.copy(src=src, dst=dst)
            time.sleep(self.time_interval)

    def generate_initial_value(self, data):
        if 'INITIAL_VALUE' in data:
            return data['INITIAL_VALUE']
        elif data['TYPE'] == 'int':
            return random.randint(data['MIN_VALUE'], data['MAX_VALUE'])
        elif data['TYPE'] == 'float':
            return random.uniform(data['MIN_VALUE'], data['MAX_VALUE'])
        elif data['TYPE'] == 'bool':
            return random.choice([True, False])
        elif data['TYPE'] == 'math_expression':
            self.expression_evaluators[data['NAME']] = ExpressionEvaluator(data['MATH_EXPRESSION'], data['INTERVAL_START'], data['INTERVAL_END'], data['MIN_DELTA'], data['MAX_DELTA'])
            return self.expression_evaluators[data['NAME']].get_current_expression_value()
            
    def generate_next_value(self, data, old_value):
        if 'RESET_PROBABILITY' in data and random.random() < data['RESET_PROBABILITY']:
            return self.generate_initial_value(data)
        if 'RESTART_ON_BOUNDARIES' in data and data['RESTART_ON_BOUNDARIES'] and (old_value == data['MIN_VALUE'] or old_value == data['MAX_VALUE']):
            return self.generate_initial_value(data)
        if random.random() < data['RETAIN_PROBABILITY']:
            return old_value
        if data['TYPE'] == 'bool':
            return not old_value
        elif data['TYPE'] == 'math_expression':
            return self.expression_evaluators[data['NAME']].evaluate_expression()
        else:
            # generating value for int or float
            step = random.uniform(0, data['MAX_STEP'])
            step = round(step) if data['TYPE'] == 'int' else step
            increase_probability = data['INCREASE_PROBABILITY'] if 'INCREASE_PROBABILITY' in data else 0.5
            if random.random() < (1 - increase_probability):
                step *= -1
            return max(old_value + step, data['MIN_VALUE']) if step < 0 else min(old_value + step, data['MAX_VALUE'])

    def generate_payload(self):
        payload = {}
        if self.old_payload == None:
            # generate initial data
            for data in self.topic_data:
                payload[data['NAME']] = self.generate_initial_value(data)
        else:
            # generate next data
            for data in self.topic_data:
                payload[data['NAME']] = self.generate_next_value(data, self.old_payload[data['NAME']])
        return payload
