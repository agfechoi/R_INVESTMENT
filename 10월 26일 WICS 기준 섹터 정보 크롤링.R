#10월 26일 WICS 기준 섹터 정보 크롤링

#지수제공업체인 와이즈인덱스에서 wics산업분류를 보여주고 있다.
#여기를 크롤링해보자

#먼저 wiseindex웹페이지에 접속해서[index -> wise sector index -> wics -> 에너지]
#클릭.(f12 network)그후 [components] 탭을 클릭하면 해당 섹터의 구성종목을 확인가능

#일자로 날짜 선택하면 [Network] 탭의 GetIndexComponets 항목을 통해 데이터 
#전송 과정이 나타남. Request URL 주소를 살펴보면

#1.http://www.wiseindex.com/Index/GetIndexComponets: 데이터를 요청하는 URL
#2. ceil_yn = 0: 실링 여부를 나타내며 0은 비실링을 의미한다.
#3. dt = 날짜 ex) 20201023
#4. sec_cd = G10 섹터 코드를 나타냄.

#이 싸이트는 json형식의 데이터이다. json형식은 문법이 단순하고 데이터의 용량이
#작아서 빠른 속도로 데이터를 교환할 수 있다.
#R에서는 jsonlite 패키지의 fromJSON() 함수를 사용해 매우 손쉽게 JSON 형식의
#데이터를 크롤링할 수 있다.

library(jsonlite)

url = paste0(
  'http://www.wiseindex.com/Index/GetIndexComponets?ceil_yn=0&dt=20201023&sec_cd=G10'
  
)

data = fromJSON(url)

lapply(data, head)

#list 항목에는 해당 섹터의 구성종목 정보가 있으며, $sector 항목을 통해 다른 섹터
#코드도 확인 가능. for loop구문을 통해서 URL의 sec_cd=에 해당하는 부분만 변경
#하면 모든 섹터의 구성종목들을 매우 쉽게 얻을 수 있다.
#섹터가 뭐뭐가 있냐하면 위 lapply에서 $sector에서 찾으면 된다.

sector_code = c('G25', 'G35', 'G50', 'G40', 'G10',
                'G20', 'G55', 'G30', 'G15', 'G45')

data_sector = list()

for (i in sector_code) {
  url = paste0(
    'http://www.wiseindex.com/Index/GetIndexComponets',
    '?ceil_yn=0&dt=20201023&sec_cd=',i)
  data = fromJSON(url)
  data = data$list
  
  data_sector[[i]] = data
  
  Sys.sleep(1)
}

View(data_sector)

data_sector = do.call(rbind, data_sector)
setwd("C:\\Users\\user\\Desktop\\new\\data")
write.csv(data_sector, 'KOR_sector.csv') #저장
