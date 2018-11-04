-- -----------------------------------------------------------
-- create dummy table, prepare for data format
-- -----------------------------------------------------------
DROP TABLE IF EXISTS `T10`;

CREATE TABLE T10 (ID INTEGER);

INSERT INTO T10 VALUES (1);
INSERT INTO T10 VALUES (2);
INSERT INTO T10 VALUES (3);
INSERT INTO T10 VALUES (4);
INSERT INTO T10 VALUES (5);
INSERT INTO T10 VALUES (6);
INSERT INTO T10 VALUES (7);
INSERT INTO T10 VALUES (8);
INSERT INTO T10 VALUES (9);
INSERT INTO T10 VALUES (10);

-- -----------------------------------------------------------
-- create formated table
-- -----------------------------------------------------------
DROP TABLE IF EXISTS `ershou_formatted`;

CREATE TABLE `ershou_formatted` (
  `id` int(11) unsigned NOT NULL,
  `city` varchar(10) DEFAULT NULL,
  `date` varchar(8) DEFAULT NULL,
  `district` varchar(50) DEFAULT NULL,
  `area` varchar(50) DEFAULT NULL,
  `ershou_title` varchar(500) DEFAULT NULL,
  `price` float(11) DEFAULT NULL,
  `detail_info` varchar(1000) DEFAULT NULL,
  `xiaoqu` varchar(50) DEFAULT NULL,
  `huxing` varchar(50) DEFAULT NULL,
  `pingfang` float(11) DEFAULT NULL,
  `chaoxiang` varchar(50) DEFAULT NULL,
  `zhuangxiu` varchar(50) DEFAULT NULL,
  `dianti` varchar(50) DEFAULT NULL,
  `image_url` varchar(1000) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- -----------------------------------------------------------
-- split detail_info into different columns
-- -----------------------------------------------------------
drop table if exists ershou_detail_info_split;

create table lianjia.ershou_detail_info_split
as
select src.id,iter.pos,
	substring_index(
    substring_index(src.detail_info,'|',iter.pos),'|',-1 ) detail_info
FROM lianjia.ershou src
inner join (select id as pos from lianjia.T10) iter
where iter.pos<=length(src.detail_info)-length(replace(src.detail_info,'|',''))+1
;

select * from lianjia.ershou_detail_info_split split3; 

-- -----------------------------------------------------------
-- data cleaning
-- -----------------------------------------------------------
select replace(trim(split3.detail_info),'平米','') 
from lianjia.ershou_detail_info_split split3
where pos = 3
group by replace(trim(split3.detail_info),'平米','') 
order by replace(trim(split3.detail_info),'平米','') 
;

select * from lianjia.ershou_detail_info_split split3
where pos = 3 and replace(trim(split3.detail_info),'平米','')  ='9室2厅'
; 

select * from lianjia.ershou;
select * from lianjia.ershou
where id=24021
;

select * from lianjia.ershou_detail_info_split split3
where id=24021
;

delete from lianjia.ershou_detail_info_split
where id=24021
;

-- -----------------------------------------------------------
-- insert into formatted target table
-- -----------------------------------------------------------

-- truncate table lianjia.ershou_formatted;
insert into lianjia.ershou_formatted
SELECT base.`id`
,base.`city`
,base.`date`
,base.`district`
,base.`area`
,base.`ershou_title`
,base.`price`
,base.`detail_info`
,split1.detail_info as xiaoqu
,split2.detail_info as huxing
,replace(trim(split3.detail_info),'平米','') as pingfang
,split4.detail_info as chaoxiang
,split5.detail_info as zhuangxiu
,split6.detail_info as dianti
,base.`image_url`
FROM lianjia.ershou base
left join lianjia.ershou_detail_info_split split1 on base.id = split1.id and split1.pos = 1
left join lianjia.ershou_detail_info_split split2 on base.id = split2.id and split2.pos = 2
left join lianjia.ershou_detail_info_split split3 on base.id = split3.id and split3.pos = 3
left join lianjia.ershou_detail_info_split split4 on base.id = split4.id and split4.pos = 4
left join lianjia.ershou_detail_info_split split5 on base.id = split5.id and split5.pos = 5
left join lianjia.ershou_detail_info_split split6 on base.id = split6.id and split6.pos = 6
;


select count(*) from lianjia.ershou;
select count(*) from lianjia.ershou_formatted;