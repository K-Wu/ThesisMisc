import requests
from lxml import html
import pandas as pd
import time
import os

INPUT_FILENAME = "techpowerup_enterprise_ssds_with_links.csv"
OUTPUT_FILENAME = "techpowerup_enterprise_ssds_with_links_and_characteristics.csv"

def test_print_all_enterprise_ssds():
    r=requests.get('https://www.techpowerup.com/ssd-specs/search/?market=2')
    doc=html.fromstring(r.content)
    print(doc.xpath('//*[@class="drives-desktop-table"]//tr'))

def test_print_one_enterprise_ssds_characteristics():
    r=requests.get('https://www.techpowerup.com/ssd-specs/solidigm-d7-ps1010-1-9-tb.d2148')
    doc=html.fromstring(r.content)
    for idx, characteristic in enumerate(doc.xpath('//*[@class="details"]//tr')):
        print(idx, characteristic.xpath('th/text()'), characteristic.xpath('td/text()'))
        # 8 ['Interface:'] ['PCIe 5.0 x4']
        # 21 ['Type'] ['TLC']
        # 22 ['Technology:'] ['176-layer']
        # 30 ['Read Time (tR):'] ['50 µs']
        # 31 ['Program Time (tProg):'] ['380 µs']
        # 32 ['Die Read Speed:'] ['1280 MB/s']
        # 33 ['Die Write Speed:'] ['168 MB/s']
        # 40 ['Sequential Read:'] ['14,500 MB/s']
        # 41 ['Sequential Write:'] ['4,100 MB/s']
        # 42 ['Random Read:'] ['2,350,000 IOPS']
        # 43 ['Random Write:'] ['150,000 IOPS']

def extract_characteristics_for_one_ssd(url:str, characteristics: dict[str, list[str]]):
    r=requests.get(url)
    doc=html.fromstring(r.content)
    found_keys: set[str] = set()
    for idx, characteristic in enumerate(doc.xpath('//*[@class="details"]//tr')):
        if len(characteristic.xpath('th/text()')) == 0:
            print("Warning: empty characteristics", idx, characteristic.xpath('th/text()'), characteristic.xpath('td/text()'))
            continue
        key = characteristic.xpath('th/text()')[0].replace(":", "")
        value = characteristic.xpath('td/text()')[0]
        if key in characteristics:
            characteristics[key].append(value)
            found_keys.add(key)
        else:
            characteristics[key] = [value]
    
    for key in characteristics:
        if key not in found_keys:
            characteristics[key].append("NotFound")

def extract_characteristics_for_all_ssds(df: pd.DataFrame, resume_flag: bool):
    characteristics = {}
    if resume_flag:
        for key in ["Interface", "Type", "Technology", "Read Time (tR)", "Program Time (tProg)", "Die Read Speed", "Die Write Speed", "Sequential Read", "Sequential Write", "Random Read", "Random Write"]:
            characteristics[key] = df[key].to_list()
            for item in reversed(characteristics[key]):
                if (item is not None) and (pd.isnull(item) == False):
                    break
                characteristics[key].pop()
    else:
        for key in ["Interface", "Type", "Technology", "Read Time (tR)", "Program Time (tProg)", "Die Read Speed", "Die Write Speed", "Sequential Read", "Sequential Write", "Random Read", "Random Write"]:
            characteristics[key] = []
    try:
        for idx, row in df.iterrows():
            if resume_flag and len(characteristics["Interface"]) > idx:
                continue
            print("Extracting characteristics for", row["link"])
            extract_characteristics_for_one_ssd(row["link"], characteristics)
            time.sleep(1)
    except Exception as e:
        print("Exception", e)
        print("Get error, store scraped data")
    for key in characteristics:
        if len(characteristics[key]) != len(df):
            if len(df) - len(characteristics[key]) > 0:
                print("Warning: missing characteristics", key, len(characteristics[key]), len(df), characteristics[key])
                characteristics[key] = characteristics[key] + [None] * (len(df) - len(characteristics[key]))
            else:            
                print("Warning: excessive number of characteristics", key, len(characteristics[key]), len(df), characteristics[key])
                characteristics[key] = characteristics[key][:len(df)]
        df[key] = characteristics[key]

if __name__ == "__main__":
    if os.path.exists(OUTPUT_FILENAME):
        df = pd.read_csv(OUTPUT_FILENAME)
        extract_characteristics_for_all_ssds(df, True)
    else:
        df = pd.read_csv(INPUT_FILENAME)
        # print(df)
        extract_characteristics_for_all_ssds(df, False)
    df.to_csv(OUTPUT_FILENAME)
    # test_print_one_enterprise_ssds_characteristics()