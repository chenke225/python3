import requests
url = 'http://www.customs.gov.cn/customs/302249/302274/302277/302276/2709048/index.html'
res = requests.get(url)
from bs4 import BeautifulSoup
res.encoding = 'utf-8'
soup = BeautifulSoup(res.text)
cont1 = soup.select('td')                        #  选择特定标签 td
print("result length is",len(cont1))

data1 = [n for n in range(0, len(cont1))]
for i in range(len(cont1)):
    data1[i] = cont1[i].text

first_i = 0                                            # 整理数据，从 '总值' 开始存放
for i in range(0,  50):
    if data1[i] == '总值':
        first_i = i

data2 = [n for n in range(0, len(cont1)-first_i)]
for k in range(0,len(cont1)-first_i):
    data2[k] = data1[first_i+k]   

print('data2 length=',len(data2))

# 去除列表字符中的\xa0
for i in range(0, len(data2)):
    temp = data2[i]
    s = "".join(temp.split())
    data2[i] = s

#  数据写入xls文件
import xlwt
wbk = xlwt.Workbook()
sheet1 = wbk.add_sheet(u'sheet1', cell_overwrite_ok = True) #创建sheet
#将数据写入第 i 行，第 j 列
table_row = 10
for i in range(0, len(data2)//table_row):    # 针对不同的表格列进行修改，例如 data2//8
        for j in range(0, 10):
            sheet1.write(i,j, data2[i*table_row+j])
        i = i + 1

wbk.save('test.xls')     # 可更改不同的写入文件名

a=1
b=2
