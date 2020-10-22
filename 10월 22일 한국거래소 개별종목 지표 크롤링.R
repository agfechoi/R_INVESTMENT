#10월 22일 개별종목 지표 크롤링

#사업별 현황 크롤링과 유사하나 요청하는 쿼리값에만 조금 차이가 있다.

library(httr)
library(rvest)
library(readr)

#10월 21일 산업별 현황 크롤링과 비슷한 과정을 거친다.
gen_otp_url = 'http://marketdata.krx.co.kr/contents/COM/GenerateOTP.jspx'
gen_otp_data = list(
  name = 'filedown',
  filetype = 'csv',
  url = 'MKD/13/1302/13020401/mkd13020401',
  market_gubun = 'ALL',
  gubun = '1',
  schdate = '20201022',
  pagePath = '/contents/MKD/13/1302/13020401/MKD13020401.jsp'
)
#query string parameter를 가져오는 부분에서 isu_cdnm, isu_cd, isu_nm, isu_srt_cd, 
#fromdate항목은 종목 구분의 개별 탭에 해당하는 부분이라 전체를 긁어오고 싶은 지금은
#필요가 읎는 항목이다. 이것들을 제외한 것들만 가져온다아아


otp = POST(gen_otp_url, query = gen_otp_data) %>% 
  read_html() %>% 
  html_text()

down_url = 'http://file.krx.co.kr/download.jspx'
down_ind = POST(down_url, query = list(code = otp),
                add_headers(referer = gen_otp_url)) %>% 
  read_html() %>% 
  html_text() %>% 
  read_csv()
print(down_ind)
#이러한 과정들을 통해 down_ind변수에는 개별종목 지표 데이터가 저장되었다.

write.csv(down_ind, 'data/krx_ind.csv')
#저장하기

