#10월 21일 한국거래소 산업별 현황 및 개별지표 크롤링
getwd()
library(httr)
library(rvest)
library(readr)

#금융데이터 수집하기 한국거래소
#한국거래소 산업별 현황 url = http://marketdata.krx.co.kr/mdi#document=03030103
#한국거래소 산업별 현황 크롤링
gen_otp_url = 
  'http://marketdata.krx.co.kr/contents/COM/GenerateOTP.jspx'
#gen_otp_url에 원하는 항목을 제출할 URL을 입력한다

gen_otp_data = list(
  name = 'filedown',
  filetype = 'csv',
  url = 'MKD/03/0303/03030103/mkd03030103',
  tp_cd = 'ALL',
  date = '20201021',
  lang = 'ko',
  pagePath = '/contents/MKD/03/0303/03030103/MKD03030103.jsp'
)
#개발자 도구 화면에 나오는 쿼리 내용들을 리스트 형태로 입력. filetype은 csv로 해야 나중에
#데이터 처리가 쉽다


otp = POST(gen_otp_url, query = gen_otp_data) %>% 
  read_html() %>% 
  html_text()
#post함수로 해당 url에 쿼리를 전송하면 이에 해당하는 데이터들을 받게된다.
#read_html로 html 내용을 읽어옴
#html_text로 html내에서 텍스트에 해당하는 부분만을 추출하고 
#위 쿼리에 의해서 otp값만 추출하게 된다.

down_url = 'http://file.krx.co.kr/download.jspx' #OTP를 제출할 URL을 down_url에 입력
down_sector = POST(down_url, query = list(code = otp), #POST함수로 otp코드를 해당url에 제출
                   add_headers(referer = gen_otp_url)) %>% #add_headers()구문으로
  # referer을 추가해야 한다. referer란 링크를 통해서 각 웹사이트로 방문할 때 남는 흔적
  #거래소 데이터를 다운로드 하는 과정을 보면 첫 url에서 otp를 부여받고, 이를 다시 
  #두번째 URL에 제출한다. 근데 이 과정이 없이 OTP를 바로 URL에 제출하면 서버는 이를
  #로봇으로 인식해서 데이터 반환 안함 그러니까 add_headers()함수로 흔적을 남겨주는것
  read_html() %>% 
  html_text() %>% 
  read_csv()

print(down_sector) # post함수로 부여받았던 것을 정제한다음 프린트!
#위 과정을 통해 down_sector 변수에는 산업별 현황 데이터가 저장되었습니다. 
#이것을 csv 파일로 저장하겠습니다.

ifelse(dir.exists('data'), FALSE, dir.create('data'))
write.csv(down_sector, 'data/krx_sector.csv')
#ifelse함수를 통해 data라는 이름의 폴더가 있으면 FALSE를 반환하고, 없으면 해당 이름으로
#폴더를 생성해줍니다. 그 후 앞서 다운로드한 데이터를 data 폴더 안에 krx_sector.csv이름
#으로 저장함. 


