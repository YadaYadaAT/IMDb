The current was a group project for the Database Systems lesson of Athens tech. Our job given was to Reverse-Enginneer few webpages of  the famous IMDb. Our group of 3 , Georgios kokkinos / Argyro Ververaki / Ioannis Balasis ,  or in other words the YadaYada production , carefully analyzed the web pages and produced the following :
->Entity Relationship Design (Chen Notation)
->Relation Schema 
->ERD (Crow foot)
->SQL (MS SQL)

Used Tools : Draw.io , Github and Git , MSSQL, Microsoft Teams 
Versions and Links 
Designed with :  	Draw.io 21.1.2
SQLversion: 	Microsoft SQL Server 2022 (RTM) - 16.0.1000.6 (X64)
Github link:  	https://github.com/Balasis/Yada_Yada.git


-SQL project characteristics:
 1)Constraints almost in every single attribute so as to ensure the correct data values(email structure,urls,dates diffs e.t.c)
2)Optimization by indexing(nonclustered) columns of specific tables such us UsersVote(ReviewID) to increase perfomance.
3)Carefully attached triggers(no cursor/lock) to keep the tables up to date(e.x VideosNum e.t.c) without affecting the perfomance.
4)Scheduled Daily Procedures/Jobs(Update Mov/Ser votes and ReviewNum) at 5 am-6 am low traffic hours
5)All counts and any other statements are carefully made in order to avoid needless repetitiveness and therefore boost perfomance.

				
																                               YadaYada
																		           Production