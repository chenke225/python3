# coding:utf-8
from selenium import webdriver
import time
from selenium.common.exceptions import NoSuchElementException, TimeoutException
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
# 创建chrome对象
url = "http://data.stats.gov.cn/easyquery.htm?cn=A01"
driver = webdriver.Chrome()
driver.get(url)

nextPage = driver.find_element_by_css_selector("#treeZhiBiao_2_span").click()
# 第二级下拉打开后，显示出下面的元素，selenium才能找到元素
try:
    nextPage = driver.find_element_by_css_selector("#treeZhiBiao_16_span").click()            
except NoSuchElementException:
    print('OMG2')
# 继续下拉显示以下元素，才能找到。但动态网页改变了元素的定位信息。
try:
    nextPage = driver.find_element_by_css_selector("#treeZhiBiao_29_span").click()           
   # nextPage = driver.find_element_by_css_selector("#treeZhiBiao_30_span").click()           
   # nextPage = driver.find_element_by_css_selector("#treeZhiBiao_31_span").click()           
   # nextPage = driver.find_element_by_css_selector("#treeZhiBiao_32_span").click()           
except NoSuchElementException:
    print('OMG2')

data1 = driver.find_elements_by_css_selector("#table_main" ) # 将css_selector定位到包含表格内容的较高级别，取出整个表作为列表的一个元素。
# data1 = driver.find_elements_by_tag_name("td" )  # tag tr 定位到表格某行，td定位到某行的某列，构成的列表有多个元素，甚至有表格外的内容。
print(len(data1))

data3 = data1[0].text.split()    # data1中一个元素包含了大字符串，用空格和\n分隔，用split方法分隔，产生所需的列表data3
print(len(data3))
print(data3)


driver.quit()
print('hello')

