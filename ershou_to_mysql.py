#!/usr/bin/env python
# coding=utf-8
# author: dong-shuai
# 此代码仅供学习与交流，请勿用于商业用途。
# read data from csv, write to mysql

import os
import pymysql
from lib.utility.path import DATA_PATH
from lib.zone.city import *
from lib.utility.date import *
from lib.utility.version import PYTHON_3
from lib.spider.base_spider import SPIDER_NAME

pymysql.install_as_MySQLdb()


def create_prompt_text():
    city_info = list()
    num = 0
    for en_name, ch_name in cities.items():
        num += 1
        city_info.append(en_name)
        city_info.append(": ")
        city_info.append(ch_name)
        if num % 4 == 0:
            city_info.append("\n")
        else:
            city_info.append(", ")
    return 'Which city data do you want to save ?\n' + ''.join(city_info)


if __name__ == '__main__':
    # 设置目标数据库
    ##################################
    # mysql only
    database = "mysql"
    ##################################
    db = None
    collection = None
    workbook = None
    datas = list()

    import records
    db = records.Database('mysql://root:123456@localhost/lianjia?charset=utf8', encoding='utf-8')


    city = get_city()
    # 准备日期信息，爬到的数据存放到日期相关文件夹下
    date = get_date_string()
    # 获得 csv 文件路径
    # date = "20180331"   # 指定采集数据的日期
    # city = "sh"         # 指定采集数据的城市
    city_ch = get_chinese_city(city)
    csv_dir = "{0}/{1}/ershou/{2}/{3}".format(DATA_PATH, SPIDER_NAME, city, date)

    files = list()
    if not os.path.exists(csv_dir):
        print("{0} does not exist.".format(csv_dir))
        print("Please run 'python ershou.py' firstly.")
        print("Bye.")
        exit(0)
    else:
        print('OK, start to process ' + get_chinese_city(city))
    for csv in os.listdir(csv_dir):
        data_csv = csv_dir + "/" + csv
        # print(data_csv)
        files.append(data_csv)

    # 清理数据
    count = 0
    row = 0
    col = 0
    for csv in files:
        with open(csv, 'r') as f:
            for line in f:
                count += 1
                text = line.strip()
                try:
                    # 如果小区名里面没有逗号，那么总共是7项
                    if text.count(',') == 6:
                        date, district, area, ershou_title, price, detail_info, image_url = text.split(',')
                    elif text.count(',') < 6:
                        continue
                    else:
                        fields = text.split(',')
                        date = fields[0]
                        district = fields[1]
                        area = fields[2]
                        ershou_title = ','.join(fields[3:-3])
                        price = fields[-3]
                        detail_info = fields[-2]
                        image_url = fields[-1]
                except Exception as e:
                    print(text)
                    print(e)
                    continue
                price = price.replace(r'暂无', '0')
                price = price.replace(r'万', '')
                price = float(price)
                print("{0} {1} {2} {3} {4} {5} {6}".format(date, district, area, ershou_title, price, detail_info, image_url))
                # 写入mysql数据库
                db.query('INSERT INTO ershou (city, date, district, area, ershou_title, price, detail_info, image_url) '
                             'VALUES(:city, :date, :district, :area, :ershou_title, :price, :detail_info, :image_url)',
                             city=city_ch, date=date, district=district, area=area, ershou_title=ershou_title, price=price,
                             detail_info=detail_info, image_url=image_url)


    print("Total write {0} items to database.".format(count))
