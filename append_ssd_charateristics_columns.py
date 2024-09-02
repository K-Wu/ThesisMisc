import requests
from lxml import html

INPUT_FILENAME = "techpowerup_enterprise_ssds.csv"
OUTPUT_FILENAME = "techpowerup_enterprise_ssds_with_characteristics.csv"

def test_print_all_enterprise_ssds():
    r=requests.get('https://www.techpowerup.com/ssd-specs/search/?market=2')
    doc=html.fromstring(r.content)
    print(doc.xpath('//*[@class="drives-desktop-table"]//tr'))

def test_print_one_enterprise_ssds_characteristics():
    r=requests.get('https://www.techpowerup.com/ssd-specs/solidigm-d7-ps1010-1-9-tb.d2148')
    doc=html.fromstring(r.content)
    for idx, characteristic in enumerate(doc.xpath('//*[@class="details"]//tr')):
        print(idx, characteristic.xpath('th/text()'), characteristic.xpath('td/text()'))
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


test_print_one_enterprise_ssds_characteristics()