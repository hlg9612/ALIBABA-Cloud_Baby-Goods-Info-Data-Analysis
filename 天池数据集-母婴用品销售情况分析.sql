#每年复购率
SELECT 下单年, COUNT(c) AS 下单人数, COUNT(if(c > 1, 1, NULL)) AS 当年复购人数, concat(round(COUNT(if(c > 1, 1, NULL)) / COUNT(c) * 100, 2), '%') AS '当年复购率'
FROM (
	SELECT YEAR(day) AS 下单年, COUNT(user_id) AS c
		FROM trade
	GROUP BY 下单年, user_id
) a
GROUP BY 下单年
ORDER BY 下单年;

#回购率
SELECT a.date, COUNT(a.user_id) AS 当月购买人数, COUNT(b.user_id) AS 次月回购人数
 , concat(round(COUNT(b.user_id) / COUNT(a.user_id) * 100, 2), '%') AS 次月回购率
FROM (
 SELECT DATE_FORMAT(day, '%Y-%m') AS date, user_id
 FROM trade
 GROUP BY date, user_id
 ORDER BY user_id
) a
 LEFT JOIN (
  SELECT DATE_FORMAT(day, '%Y-%m') AS date, user_id
  FROM trade
  GROUP BY date, user_id
  ORDER BY user_id
 ) b
 ON a.user_id = b.user_id
  AND a.date = date_sub(b.date, INTERVAL 1 MONTH)
GROUP BY date

# 双十一期间购物的老客
SELECT*
	FROM
    trade
WHERE user_id in(
	SELECT user_id
	FROM trade
	GROUP BY user_id
	HAVING count(user_id)>1)
	and month(day) = 12 and day(day) = 12;

#六大品类总体销售额
SELECT cat1,sum(buy_mount) FROM data.trade
GROUP BY cat1;

#各大类月销量

    SELECT cat1 as 类目, sum(buy_mount) as 月销量, concat(year(day) , '-', month(day)) as 时间, year(day) as 年份,month(day) as 月份
		FROM trade
	GROUP BY 类目,时间
	ORDER BY 年份,月份, cat1;
    
#热门小类
SELECT a.大类, a.小类, 销量, a.i as 销量排名, 购买人次, b.j as 购买人次排名
FROM 
	(SELECT 大类, 小类, 销量, @i:=@i+1 as i
		FROM (SELECT @i:=0) as i,
			(SELECT CONCAT(cat1,'大类') as 大类, CONCAT(cat_id,'小类') as 小类, sum(buy_mount) as 销量
				FROM trade 
			GROUP BY cat_id,cat1
            ORDER BY 销量 DESC)as t1
	LIMIT 10) as a
INNER JOIN
	(SELECT 大类, 小类, 购买人次, @j:=@j+1 as j
		FROM (SELECT @j:=0) as j,
			(SELECT CONCAT(cat1,'大类') as 大类, CONCAT(cat_id,'小类') as 小类, count(user_id) as 购买人次
				FROM trade 
			GROUP BY cat_id,cat1
            ORDER BY 购买人次 DESC)as t2
	LIMIT 10) as b
ON a.小类 = b.小类
ORDER BY a.大类;
            
##分析各优秀小类产品的销量、客户数量趋势
SELECT CONCAT(YEAR(day),'-', MONTH(day)) as 年月,sum(buy_mount) as 销量, count(user_id) as 购买人次,cat_id
	FROM trade
WHERE cat_id in (50013636,50010558,50013207,50006602)
GROUP BY date_format(day, '%Y-%M'), cat_id
ORDER BY YEAR(day), MONTH(day)
    
#用户画像
SELECT 
	CASE
    when gender = 0 then '男'
    when gender = 1 then '女'
    when gender = 2 then '不明'
    end as 性别, 
    CASE
    when datediff(day,birthday)/365 <1 then '0-1岁'
    when datediff(day,birthday)/365 <2 then '1-2岁'
    when datediff(day,birthday)/365 <3 then '2-3岁'
    when datediff(day,birthday)/365 <4 then '3-4岁'
    when datediff(day,birthday)/365 <5 then '4-5岁'
    when datediff(day,birthday)/365 <6 then '5-6岁'
    when datediff(day,birthday)/365 <7 then '6-7岁'
    else '7岁以上' end as 年龄, CONCAT(YEAR(day),'-', MONTH(day)) as 年月 ,t.user_id, cat_id, cat1, buy_mount
	FROM 
	trade t
INNER JOIN
	baby b
ON t.user_id = b.user_id

	