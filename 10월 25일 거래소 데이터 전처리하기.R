getwd()
setwd("C:/Users/user/Desktop/new/data")

#10월 25일 거래소 데이터 정리하기
#앞에서 다운로드한 데이터는 중복된 열이 있으며, 불필요한 데이터 역시 있으므로
#하나의 테이블로 합친 후 정리할 필요가 있다. 

down_sector <- read.csv("krx_sector.csv", row.names = 1,
                        stringsAsFactors = FALSE)
down_ind <- read.csv("krx_ind.csv", row.names = 1,
                     stringsAsFactors = FALSE)
#row.names = 1 이 뜻하는 것은 첫번째 열을 행 이름으로 지정한 다는 것.
#stringasfactors = false를 통해서 문자열 데이터가 팩터 형태로 변형되지 않게 한다.
head(down_sector)
head(down_ind)

intersect(names(down_sector), names(down_ind))
#intersect 함수를 통해 두 데이터 간 중복되는 열 이름을 살펴보면 종목코드와 종목명이
#동일한 위치에 있다. 

setdiff(down_sector[, '종목명'], down_ind[, '종목명'])
#setdiff 함수를 통해 두 데이터에 공통으로 없는 종목명, 즉 하나의 데이터에만 있는 종목을
#살펴보면 위와 같다. 해당 종목들은 선박펀드, 광물펀드, 해외종목펀드 등 일반적이지
#않은 종목들이므로 제외하는 것이 좋겠다. 따라서 둘 사이에 공통적으로 존재하는
#종목들을 기준으로 데이터를 합쳐주기로 하자.

KOR_ticker <- merge(down_sector, down_ind,
                    by = intersect(names(down_sector),
                                   names(down_ind)),
                    all = FALSE)

#merge함수는 by를 기준으로 두 데이터를 하나로 합친다. 공통으로 존재하는 종목코드,
#종목명을 기준으로 입력해준다. 또한 all 값을 TRUE로 설정하면 합집합을 반환하고
#FALSE로 설정하면 교집합을 반환한다. 공통으로 존재하는 항목(교집합)을 원하므로 여기서는 
#FALSE를 입력한다.

KOR_ticker <- KOR_ticker[order(-KOR_ticker['시가총액.원.']), ]
KOR_ticker
#데이터를 시가총액 기준으로 내림차순 정렬한 것이다. ORDER 함수를 통해 상대적인 순서를
#구할 수 있다. R은 기본적으로 순서를 오름차순으로 주므로 앞에 -를 붙여서 내림차순으로
#바꾼다. 결과적으로 시가총액 기준 내림차순으로 데이터가 정렬된다.

#마지막으로 스팩, 우선주 종목 역시 제외해주어야 한다.
KOR_ticker[grepl('스팩', KOR_ticker[, '종목명']), '종목명']

KOR_ticker[substr(KOR_ticker[, '종목명'],
                  nchar(KOR_ticker[, '종목명']),
                  nchar(KOR_ticker[, '종목명'])) == '우', '종목명']

KOR_ticker[substr(KOR_ticker[, '종목명'],
                  nchar(KOR_ticker[, '종목명']) -1,
                  nchar(KOR_ticker[, '종목명'])) == '우B', '종목명']

KOR_ticker[substr(KOR_ticker[, '종목명'],
                  nchar(KOR_ticker[, '종목명']) -1,
                  nchar(KOR_ticker[, '종목명'])) == '우C', '종목명']

#grepl 함수를 통해 종목명에 '스팩'이 들어가는 종목을 찾고,
#substr함수를 통해 종목명 끝이 '우', '우B', '우C'인 우선주 종목을 찾을 수 있다.
#데이터 내에서 해당 데이터들을 제거한다.

KOR_ticker <- KOR_ticker[!grepl('스팩', KOR_ticker[, '종목명']), ]

KOR_ticker <- KOR_ticker[substr(KOR_ticker[, '종목명'],
                                nchar(KOR_ticker[, '종목명']),
                                nchar(KOR_ticker[, '종목명'])) !='우', ]

KOR_ticker <- KOR_ticker[substr(KOR_ticker[, '종목명'],
                                nchar(KOR_ticker[, '종목명']) -1,
                                nchar(KOR_ticker[, '종목명'])) !='우B', ]

KOR_ticker <- KOR_ticker[substr(KOR_ticker[, '종목명'],
                                nchar(KOR_ticker[, '종목명']) -1,
                                nchar(KOR_ticker[, '종목명'])) !='우C', ]

#제거 완료

#마지막으로 행 이름을 초기화 한후 정리된 데이터를 CSV파일로 저장한다.
rownames(KOR_ticker) = NULL
write.csv(KOR_ticker, 'KOR_ticker.csv')
KOR_ticker
