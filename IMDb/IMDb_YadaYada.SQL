

												--[Flow of Creation:]
				--1)Tables without FK's(1 function included
				--2)Procedures/Jobs(Updating Movie/Series vote,ReviewsNum e.t.c (Programmed to 5 and 6 AM [less people inside /no overload])
																			--(Ms sql Agent needs to be active)
				--3)Triggers(updating VotesNum,Videos-PictureNum e.t.c)
				--4)index(only 1),Functions(1)
				--5)ForeignKeys
				--6)Insert Commands (Populate sample of 5 rows...)


																
--Brought to you by YadaYada production .
IF EXISTS(SELECT name FROM master.dbo.sysdatabases WHERE name = 'IMDb_YadaYada')
BEGIN
  ALTER DATABASE IMDb_YadaYada SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
  DROP DATABASE IMDb_YadaYada;
END

CREATE DATABASE IMDb_YadaYada;
GO
USE IMDb_YadaYada;


CREATE TABLE Award (
    AwardID BIGINT NOT NULL IDENTITY(1,1),
    SeriesID BIGINT,
    MoviesID BIGINT,
    FilmCrewID BIGINT NOT NULL,
    AcademyAward BIT,
    GoldenGlobe BIT,
    AcademyAwardTitle INT,
    GoldenGlobeTitle INT,
    WinnerOrNom BIT,
    Date DATE,
    Location NVARCHAR(100),
    Comment NVARCHAR(MAX),
    OscarOrGolden NVARCHAR(20) NOT NULL CONSTRAINT OscarOrGolden CHECK(OscarOrGolden IN ('Oscar','Golden Globe')),
	CONSTRAINT cantHaveBothSeriesAndMovie CHECK ((SeriesID IS NULL AND MoviesID IS NOT NULL)or(SeriesID IS NOT NULL AND MoviesID IS NULL)   ),
	CONSTRAINT cantHaveBothAwards CHECK ((AcademyAward IS NULL AND GoldenGlobe IS NOT NULL)or(AcademyAward IS NOT NULL AND GoldenGlobe IS NULL)   ),
   CONSTRAINT AW_titleOnlyIf_AcadAwardhasvalue CHECK  ((AcademyAward IS NULL AND AcademyAwardTitle IS  NULL) OR (GoldenGlobe IS  NULL AND GoldenGlobeTitle IS NULL)), 
   CONSTRAINT oscarOrGoldenGlobeAccordinglyToTypeOfAward CHECK ((AcademyAward IS NOT NULL  AND OscarOrGolden='Oscar')OR (GoldenGlobe IS NOT NULL AND OscarOrGolden='Golden Globe'))


);
GO


CREATE TABLE AcademyAwTitles (
  AcademyAwardID INT PRIMARY KEY IDENTITY(1,1),
  AcademyAwardTitle NVARCHAR(50)
  CONSTRAINT DOonotBeginwithSpace check (AcademyAwardTitle NOT LIKE ' %'),
  CONSTRAINT DOonotADDSpacesInTheENd check(AcademyAwardTitle NOT LIKE '% '),
  CONSTRAINT AcademyAwTitlesALreadyExist UNIQUE (AcademyAwardTitle)
);
GO



CREATE TABLE Critic (
  CriticID BIGINT PRIMARY KEY IDENTITY(1,1),
  URL NVARCHAR(100) CONSTRAINT CriticURLMustBeSecure CHECK (URL LIKE 'https://%[a-zA-Z0-9_/]%'),
  SeriesID BIGINT,
  MoviesID BIGINT,
  CONSTRAINT MOvorRRseriesBeEnabled CHECK ( (SeriesID IS NULL AND MoviesID IS NOT NULL) OR  (SeriesID IS NOT NULL AND MoviesID IS  NULL))
);
GO



CREATE FUNCTION dbo.age
(
    @BornDate DATE,
    @DeathDate DATE
)
RETURNS INT
AS
BEGIN
    DECLARE @Age INT, @BornDateLocal DATE, @DeathDateLocal DATE
    SET @BornDateLocal = @BornDate
    SET @DeathDateLocal = @DeathDate
    IF @DeathDateLocal IS NOT NULL
        SET @Age = DATEDIFF(YEAR, @BornDateLocal, @DeathDateLocal)
    ELSE
        SET @Age = DATEDIFF(YEAR, @BornDateLocal, GETDATE())
    RETURN @Age
END

GO


CREATE TABLE FilmCrew (
    FilmCrewID BIGINT PRIMARY KEY IDENTITY (1,1),
    FirstName NVARCHAR(20) NOT NULL,
    LastName NVARCHAR(20) NOT NULL,
    BornLocation NVARCHAR(100) ,
    DeathLocation NVARCHAR(100),
    BornDate DATE NOT NULL,
    DeathDate DATE ,
    Description NVARCHAR(MAX),
    FullName AS CONCAT(FirstName, ' ', LastName) PERSISTED,
    Top1Job NVARCHAR(50) NULL,
    Top2Job NVARCHAR(50) NULL,
    Top3Job NVARCHAR(50) NULL,
    Age AS dbo.Age(BornDate,DeathDate),
    VidNum INT NULL,
    PicNum INT NULL,
	CONSTRAINT FullnamEe_MustBe_FirstAndLastName CHECK (Fullname=CONCAT(FirstName, ' ', LastName)),
	CONSTRAINT DeathDateCantBesmallerThanBornDate CHECK ((DeathDate IS NOT NULL AND BornDate<DeathDate)OR (DeathDate IS NULL ))
);
GO


CREATE TABLE Genre (
  GenreID INT PRIMARY KEY IDENTITY(1,1),
  GenreTitle NVARCHAR(50) ,
  CONSTRAINT genreNospace CHECK (GenreTitle NOT LIKE '[^ ]'),
  CONSTRAINT DOnotBeginwithSpace check (GenreTitle NOT LIKE ' %'),
  CONSTRAINT DOnotADDSpacesInTheENd check(GenreTitle NOT LIKE '% ')
);
GO

CREATE TABLE GoldenGlobeTitles (
  GoldenGlobeID INT PRIMARY KEY IDENTITY (1,1),
  GoldenGlobeTitle NVARCHAR(50)
    CONSTRAINT DOonottBeginwithSpace check (GoldenGlobeTitle NOT LIKE ' %'),
  CONSTRAINT DOonottADDSpacesInTheENd check(GoldenGlobeTitle NOT LIKE '% '),
  CONSTRAINT GoldenGlobeTitleUnique UNIQUE(GoldenGlobeTitle)
);
GO


CREATE TABLE Image(
ImageID BIGINT Primary key IDENTITY(1,1),
SeriesID BIGINT,
MovieID BIGINT,
URL NVARCHAR(100) CONSTRAINT URLrelativeStruc CHECK (URL LIKE '%/[a-zA-Z0-9_/]%'),
Info NVARCHAR(100),
CONSTRAINT ChooseSeriesIDOrMovieIDnotBothh CHECK ( (SeriesID is null and MovieID IS NOT NULL) OR (SeriesID IS NOT NULL and MovieID is NULL) )

)

GO


CREATE TABLE Job (
    JobID INT PRIMARY KEY IDENTITY(1,1),
    MemberOfCrewID BIGINT NOT NULL,
    JobsTitlesID INT NOT NULL,
    Description NVARCHAR(MAX),
    StarOrNot BIT,
    Role NVARCHAR(100),
 
);


GO


CREATE TABLE JobsTitle (
    JobsID INT PRIMARY KEY IDENTITY(1,1),
    JobsTitle NVARCHAR(100),
	CONSTRAINT DONnotBeginwithSpace check (JobsTitle NOT LIKE ' %'),
  CONSTRAINT DONnotADDSpacesInTheENd check(JobsTitle NOT LIKE '% ')
);
GO

CREATE TABLE MemberOfCrew (
    MemberOfCrewID BIGINT PRIMARY KEY IDENTITY(1,1),
    FilmCrewID BIGINT NOT NULL,
    SeriesID BIGINT,
    MoviesID BIGINT,
    MoviesOrSeries NVARCHAR(30) NOT NULL,
  CONSTRAINT eITHERmovORseries  CHECK((MoviesID IS NULL AND SeriesID IS NOT NULL) OR (SeriesID IS NULL AND MoviesID IS NOT NULL)),
  CONSTRAINT UniGroup UNIQUE (FilmCrewID,SeriesID,MoviesID),
   CONSTRAINT MovieOrSeries CHECK((lower(MoviesOrSeries)='movie' AND MoviesID IS NOT NULL)OR(lower(MoviesOrSeries)='series') AND SeriesID IS NOT NULL )
);
GO


CREATE TABLE Movie (
  MoviesID BIGINT PRIMARY KEY IDENTITY (1,1),
  Genre1 INT NOT NULL,
  Genre2 INT,
  Genre3 INT,
  R NVARCHAR(10),
  Duration TIME(0),
  Description NVARCHAR(MAX) CONSTRAINT MoviesDescriptionCantBeEmpty CHECK(LEN(LTRIM(RTRIM(Description))) <>0),
  ReleaseYear INT NOT NULL,
  ReleaseDate DATE NOT NULL,
  TrailerURL NVARCHAR(100) CONSTRAINT MoviesTrailerURLstructure CHECK (TrailerURL LIKE '%/[a-zA-Z0-9_/]%'),
  Title NVARCHAR(100) NOT NULL CONSTRAINT MoviesTitleCantBeOnlySpaces CHECK(LEN(LTRIM(RTRIM(Title))) <>0),
  CoverURL NVARCHAR(100)  CONSTRAINT MoviesCoverURLstructure CHECK (CoverURL LIKE '%/[a-zA-Z0-9_/]%'),
  Location NVARCHAR(100),
  VideosNum INT default 0,
  ImagesNum INT default 0,
  ReviewsNum BIGINT default 0,
  PopularityDiff INT default 0,
  PageViewsNum BIGINT default 0,
  TopRatedTV INT,
  StarRating NUMERIC(2,1),
  AwardWinsNum INT default 0,
  AwardNominNum INT default 0,
  Popularity INT,
  CONSTRAINT checkReleaseDateWithYear CHECK (DATEDIFF(YEAR,CAST(cast(ReleaseYear AS varchar(4))+'-01-01' AS DATE) ,ReleaseDate)=0)
);
GO


CREATE TABLE PicOrVidURL (
    PicOrVidURLID BIGINT PRIMARY KEY IDENTITY(1,1),
    FilmCrewID BIGINT NOT NULL,
    URL NVARCHAR(100) NOT NULL CONSTRAINT pICOrVidURLstructure CHECK (URL LIKE '%/[a-zA-Z0-9_/]%'),
    IsItPicOrVid BIT NOT NULL,
    Comment NVARCHAR(MAX),
   
);
GO






CREATE TABLE Review (
  ReviewID BIGINT PRIMARY KEY IDENTITY(1,1),
  UsersID BIGINT NOT NULL,
  SeriesID BIGINT,
  MoviesID BIGINT,
  Spoiler BIT,
  Date  DATETIME NULL DEFAULT GETDATE(),
  Header NVARCHAR(100) CONSTRAINT lengthCantBeZero CHECK(LEN(LTRIM(RTRIM(Header)))<>0),
  Body NVARCHAR(200) NOT NULL,
  VotesNum BIGINT NULL,
  VotesPlus BIGINT NULL,
  CONSTRAINT EitherSeriesORMovie CHECK ((SeriesID IS NOT NULL AND MoviesID IS NULL) OR (SeriesID IS NULL and MoviesID IS NOT NULL))
);
GO


CREATE TABLE Series (
  SeriesID BIGINT PRIMARY KEY IDENTITY(1,1),
  Genre1 INT NOT NULL,
  Genre2 INT,
  Genre3 INT,
  R NVARCHAR(10),
  Media NVARCHAR(100),
  Duration TIME(0),
  Timespan NVARCHAR(20),
  Description NVARCHAR(MAX) CONSTRAINT SeriesDescriptionCantBeEmpty CHECK(LEN(LTRIM(RTRIM(Description))) <>0),
  Seasons INT CONSTRAINT SeriesSeasonsAtLeastOne CHECK(Seasons >=1),
  EpisodesNum INT CONSTRAINT EpisodesNumAtLeastOne CHECK(EpisodesNum >=1),
  Years INT ,
  TrailerURL NVARCHAR(100) CONSTRAINT SeriesTrailerURLstructure CHECK (TrailerURL LIKE '%/[a-zA-Z0-9_/]%'),
  Title NVARCHAR(100) NOT NULL CONSTRAINT SeriesTitleCantBeOnlySpaces CHECK(LEN(LTRIM(RTRIM(Title))) <>0),
  CoverURL NVARCHAR(100) CONSTRAINT SeriesCoverURLstructure CHECK (CoverURL LIKE '%/[a-zA-Z0-9_/]%'),
  VideosNum BIGINT NULL default 0,
  ImagesNum BIGINT NULL default 0,
  ReviewsNum BIGINT NULL default 0,
    PopularityDiff INT NULL default 0,
  TopRatedTV INT NULL,
   StarRating NUMERIC(2,1) NULL,
   Popularity INT NULL,
   AwardWinsNum INT NULL default 0,
   PageViewsNum INT NULL default 0,
  AwardNominNum INT NULL default 0,
  )
GO


CREATE TABLE [User] (
  UsersID BIGINT PRIMARY KEY IDENTITY(1,1),
  FirstName NVARCHAR(20) NOT NULL CONSTRAINT FirstName_MustBe_2To20Char_FirstTwoMustBeNotBeNumeric CHECK (LEN(FirstName) >=2 AND FirstName Like '[A-Za-z][A-Za-z]%' AND FirstNAME NOT LIKE '% %'),
  LastName NVARCHAR(20) NOT NULL CONSTRAINT LastName_MustBe_2To20Char_FirstTwoMustBeNotBeNumeric CHECK (LEN(LastName) >=2 AND LastName Like '[A-Za-z][A-Za-z]%' AND LastName NOT LIKE '% %'),
  Session_ID NVARCHAR(100),
  Password NVARCHAR(20) NOT NULL CONSTRAINT Password_MustBe_8To20Chars CHECK (LEN(Password) >=8 AND Password NOT LIKE '%[^a-zA-Z0-9]%'),
  Email NVARCHAR(100) NOT NULL CHECK (lower(Email) LIKE '%@gmail.com' OR lower(Email) LIKE '%@outlook.com' OR lower(Email) LIKE '%@yahoo.com'),
  FullName AS CONCAT(FirstName, ' ', LastName) PERSISTED,
  CONSTRAINT Fullname_MustBe_FirstAndLastName CHECK (Fullname=CONCAT(FirstName, ' ', LastName)),
  CONSTRAINT emailNoSpace CHECK (Email NOT LIKE '% %'),
  CONSTRAINT emailStructure CHECK (Email LIKE '%_@__%.__%'),
  CONSTRAINT EmailAlreadyExist UNIQUE(Email)

);
GO


CREATE TABLE UsersVote (
  UsersID BIGINT NOT NULL,
  ReviewID BIGINT NOT NULL,
  Vote INT CHECK(VOTE IN (0,1)) NOT NULL,
  CONSTRAINT PK_UsersVote PRIMARY KEY (UsersID, ReviewID)
);
GO



CREATE TABLE Video(
VideoID BIGINT Primary key IDENTITY(1,1),
SeriesID BIGINT,
MovieID BIGINT,
URL NVARCHAR(100) CONSTRAINT URLMustBeSecure CHECK (URL LIKE '%/[a-zA-Z0-9_/]%'),
Info NVARCHAR(100),
CONSTRAINT ChooseSeriesIDOrMovieIDnotBoth CHECK ( (SeriesID is null and MovieID IS NOT NULL) OR (SeriesID IS NOT NULL and MovieID is NULL) )

)

GO


CREATE TABLE VoteForM (
  MoviesID BIGINT NOT NULL,
  UsersID BIGINT NOT NULL,
  Vote NUMERIC(2,0) NOT NULL CONSTRAINT voteforMvote CHECK(VOTE BETWEEN 1 AND 10),
  VoteDate DATETIME NULL DEFAULT GETDATE(),
  PRIMARY KEY (MoviesID, UsersID),
 
);
GO


CREATE TABLE VoteForS (
  SeriesID BIGINT NOT NULL,
  UsersID BIGINT NOT NULL,
  Vote NUMERIC(2,0) NOT NULL CHECK (Vote BETWEEN 1 AND 10),
  VoteDate DATETIME NULL DEFAULT GETDATE(),
  PRIMARY KEY(SeriesID,UsersID)
);
GO

CREATE TABLE LastUpdateVotes(
LastUpdateVotesID INT PRIMARY KEY IDENTITY(1,1),
LastUpdate DATE
)

GO








CREATE Procedure dbo.ScheduledVotes
AS
BEGIN
DECLARE @LastUpdated DATE
SET @LastUpdated=(SELECT MAX(LastUpdate) FROM LastUpdateVotes)


 UPDATE Series
SET StarRating = ( 	
    (SELECT SUM(Vote) FROM VoteForS WHERE VoteForS.SeriesID = Series.SeriesID AND VoteForS.VoteDate>@LastUpdated)/(SELECT COUNT(*) FROM VoteForS WHERE VoteForS.VoteDate>@LastUpdated AND VoteForS.SeriesID=Series.SeriesID)  )
	 
UPDATE Movie
SET StarRating = ( 	
    (SELECT SUM(Vote) FROM VoteForM WHERE VoteForM.MoviesID = Movie.MoviesID AND VoteForM.VoteDate>@LastUpdated)/(SELECT COUNT(*) FROM VoteForM WHERE VoteForM.VoteDate>@LastUpdated AND VoteForM.MoviesID=Movie.MoviesID)  )
	 INSERT INTO LastUpdateVotes(LastUpdate) VALUES (GETDATE());
END

GO
DECLARE @job_name NVARCHAR(128);
SET @job_name = N'ScheduledVotes_'+CAST(NEWID() AS NVARCHAR(36));

DECLARE @job_id UNIQUEIDENTIFIER;
EXEC msdb.dbo.sp_add_job
    @job_name = @job_name,
    @job_id = @job_id OUTPUT;

	
DECLARE @job_description NVARCHAR(MAX);
SET @job_description = N'FillTheStarRates_' +CAST(NEWID() AS NVARCHAR(36));

DECLARE @command NVARCHAR(MAX);
SET @command = N'EXEC ' + DB_NAME() + '.dbo.ScheduledVotes';
EXEC msdb.dbo.sp_add_jobstep 
    @job_name = @job_name,
    @step_name = N'Otinane',
    @subsystem = N'TSQL',
    @command = @command,
    @retry_attempts = 5,--sometimes procedure fail so here you tell it how many times to retry
    @retry_interval = 1;-- and here how much time to wait after each try

DECLARE @schedule_name NVARCHAR(128);
SET @schedule_name = N'DenToVlepwNaKimame_'+CAST(NEWID() AS NVARCHAR(36));

EXEC msdb.dbo.sp_add_schedule 
    @schedule_name = @schedule_name,
    @freq_type = 4,--4means daily.Ifyou want weekly go for 8 or monthly for 8 (but not suggested this is rating MovAndSer) 
    @freq_interval = 1,--every when..if freq type is 4 means 1 means every day,if it was 8 means every week e.t.c
    @active_start_time = 050000;--the time here is like HH/MM/SS

EXEC msdb.dbo.sp_attach_schedule
    @job_name = @job_name,
    @schedule_name = @schedule_name;

EXEC msdb.dbo.sp_add_jobserver
    @job_name = @job_name;

GO


--The following creates a procedure and also a job. The job is actually a scheduled process which grabs the procedure and executes it in a specific time
--Adgust it to your own needs. I have comments that helps you to set it out below.

CREATE Procedure dbo.UpdateReviewsNum
AS
BEGIN



 UPDATE Series
SET ReviewsNum =(SELECT COUNT(*) FROM Review WHERE Review.SeriesID = Series.SeriesID) ;
	
	 
 UPDATE Movie
 SET ReviewsNum =(SELECT COUNT(*) FROM Review WHERE Review.MoviesID = Movie.MoviesID) ;
END

GO
DECLARE @job_name NVARCHAR(128);
SET @job_name = N'UpdateReviewsNum_'+CAST(NEWID() AS NVARCHAR(36));

DECLARE @job_id UNIQUEIDENTIFIER;
EXEC msdb.dbo.sp_add_job
    @job_name = @job_name,
    @job_id = @job_id OUTPUT;

	
DECLARE @job_description NVARCHAR(MAX);
SET @job_description = N'FillTheStarRates_' +CAST(NEWID() AS NVARCHAR(36));

DECLARE @command NVARCHAR(MAX);
SET @command = N'EXEC ' + DB_NAME() + '.dbo.UpdateReviewsNum';
EXEC msdb.dbo.sp_add_jobstep 
    @job_name = @job_name,
    @step_name = N'Otinane',
    @subsystem = N'TSQL',
    @command = @command,
    @retry_attempts = 5,--sometimes procedure fail so here you tell it how many times to retry
    @retry_interval = 1;-- and here how much time to wait after each try

DECLARE @schedule_name NVARCHAR(128);
SET @schedule_name = N'DenToVlepwNaKimame_'+CAST(NEWID() AS NVARCHAR(36));

EXEC msdb.dbo.sp_add_schedule 
    @schedule_name = @schedule_name,
    @freq_type = 4,--4means daily.Ifyou want weekly go for 8 or monthly for 8 (but not suggested this is rating MovAndSer) 
    @freq_interval = 1,--every when..if freq type is 4 means 1 means every day,if it was 8 means every week e.t.c
    @active_start_time = 060000;--the time here is like HH/MM/SS

EXEC msdb.dbo.sp_attach_schedule
    @job_name = @job_name,
    @schedule_name = @schedule_name;

EXEC msdb.dbo.sp_add_jobserver
    @job_name = @job_name;
GO








--Like the videos this one update the number of images in Movie or series





CREATE TRIGGER [dbo].[ImageNum]
  ON [dbo].[Image] AFTER INSERT,UPDATE,DELETE
AS
BEGIN   
IF EXISTS(SELECT * FROM INSERTED) 
BEGIN		
	IF EXISTS(SELECT MovieID FROM INSERTED WHERE MovieID IS NOT NULL)
	BEGIN
	UPDATE Movie SET ImagesNum=(SELECT COUNT(Image.MovieID)  From Image INNER JOIN inserted ON Image.MovieID=inserted.MovieID WHERE Image.MovieID=Movie.MoviesID GROUP BY Image.MovieID)	FROM Movie INNER JOIN inserted ON Movie.MoviesID=inserted.MovieID WHERE Movie.MoviesID=inserted.MovieID AND inserted.MovieID IS NOT NULL;
	END
	 IF EXISTS(SELECT SeriesID FROM INSERTED WHERE SeriesID IS NOT NULL)
	BEGIN
	UPDATE Series SET ImagesNum=(SELECT COUNT(Image.SeriesID) FROM Image INNER JOIN inserted ON Image.SeriesID=inserted.SeriesID WHERE Image.SeriesID=Series.SeriesID GROUP BY Image.SeriesID)FROM Series INNER JOIN inserted ON Series.SeriesID=inserted.SeriesID WHERE Series.SeriesID=inserted.SeriesID AND inserted.SeriesID IS NOT NULL;
	END
END
IF EXISTS(SELECT * FROM DELETED) 
BEGIN		
	IF EXISTS(SELECT MovieID FROM DELETED WHERE MovieID IS NOT NULL)
	BEGIN
	UPDATE Movie SET ImagesNum=(SELECT COUNT(Image.MovieID)  From Image INNER JOIN DELETED ON Image.MovieID=DELETED.MovieID WHERE Image.MovieID=Movie.MoviesID GROUP BY Image.MovieID)	FROM Movie INNER JOIN DELETED ON Movie.MoviesID=DELETED.MovieID WHERE Movie.MoviesID=DELETED.MovieID AND DELETED.MovieID IS NOT NULL;
	END
	 IF EXISTS(SELECT SeriesID FROM DELETED WHERE SeriesID IS NOT NULL)
	BEGIN
	UPDATE Series SET ImagesNum=(SELECT COUNT(Image.SeriesID) FROM Image INNER JOIN DELETED ON Image.SeriesID=DELETED.SeriesID WHERE Image.SeriesID=Series.SeriesID GROUP BY Image.SeriesID)FROM Series INNER JOIN DELETED ON Series.SeriesID=DELETED.SeriesID WHERE Series.SeriesID=DELETED.SeriesID AND DELETED.SeriesID IS NOT NULL;
	END
END

END
GO


--update the number of videos or photos of the filmCrew
CREATE TRIGGER [dbo].[PicOrVidOfFilmCrew]
ON [dbo].[PicOrVidURL] AFTER INSERT,UPDATE,DELETE
AS
BEGIN

IF EXISTS(SELECT * FROM INSERTED) 
BEGIN

 UPDATE FilmCrew SET 
 PicNum=( SELECT COUNT(DISTINCT(PicOrVidURL.PicOrVidURLID)) FROM PicOrVidURL INNER JOIN INSERTED ON PicOrVidURL.FilmCrewID=inserted.FilmCrewID 
 WHERE PicOrVidURL.FilmCrewID=FilmCrew.FilmCrewID AND PicOrVidURL.IsItPicOrVid=0 GROUP BY PicOrVidURL.FilmCrewID) 
 WHERE FilmCrewID IN (SELECT FilmCrewID FROM INSERTED) ;

 UPDATE FilmCrew SET
  VidNum=( SELECT COUNT(DISTINCT(PicOrVidURL.PicOrVidURLID)) FROM PicOrVidURL INNER JOIN INSERTED ON PicOrVidURL.FilmCrewID=inserted.FilmCrewID 
 WHERE PicOrVidURL.FilmCrewID=FilmCrew.FilmCrewID AND PicOrVidURL.IsItPicOrVid=1  GROUP BY PicOrVidURL.FilmCrewID)
  WHERE FilmCrewID IN (SELECT FilmCrewID FROM INSERTED) ;


END


IF EXISTS(SELECT * FROM DELETED) 
BEGIN

 UPDATE FilmCrew SET 
 PicNum=( SELECT COUNT(DISTINCT(PicOrVidURL.PicOrVidURLID)) FROM PicOrVidURL INNER JOIN DELETED ON PicOrVidURL.FilmCrewID=DELETED.FilmCrewID 
 WHERE PicOrVidURL.FilmCrewID=FilmCrew.FilmCrewID AND PicOrVidURL.IsItPicOrVid=0  GROUP BY PicOrVidURL.FilmCrewID) 
   WHERE FilmCrewID IN (SELECT FilmCrewID FROM DELETED) 

  UPDATE FilmCrew SET 
  VidNum=( SELECT COUNT(DISTINCT(PicOrVidURL.PicOrVidURLID)) FROM PicOrVidURL INNER JOIN DELETED ON PicOrVidURL.FilmCrewID=DELETED.FilmCrewID 
 WHERE PicOrVidURL.FilmCrewID=FilmCrew.FilmCrewID AND PicOrVidURL.IsItPicOrVid=1 GROUP BY PicOrVidURL.FilmCrewID)
  WHERE FilmCrewID IN (SELECT FilmCrewID FROM DELETED) 


END


 END




GO



-- The following Updates the votes in each review
CREATE TRIGGER [dbo].[UpdateVotes]
On [dbo].[UsersVote]
AFTER INSERT,UPDATE,DELETE
AS
BEGIN

IF EXISTS(SELECT * FROM INSERTED) 
BEGIN
UPDATE Review
SET VotesNum=(SELECT COUNT(DISTINCT UsersVote.Vote) FROM UsersVote INNER JOIN INSERTED 
	ON UsersVote.ReviewID=inserted.ReviewID AND UsersVote.UsersID=inserted.UsersID
	INNER JOIN [User] ON UsersVote.UsersID=[User].UsersID
WHERE UsersVote.ReviewID=Review.ReviewID  AND UsersVote.UsersID=[User].UsersID),

VotesPlus=(SELECT COUNT(DISTINCT UsersVote.Vote) FROM UsersVote INNER JOIN INSERTED 
	ON UsersVote.ReviewID=inserted.ReviewID AND UsersVote.UsersID=inserted.UsersID
	INNER JOIN [User] ON UsersVote.UsersID=[User].UsersID
WHERE UsersVote.ReviewID=Review.ReviewID  AND UsersVote.UsersID=[User].UsersID AND UsersVote.Vote=1)

FROM Review INNER JOIN inserted ON Review.ReviewID=inserted.ReviewID WHERE Review.ReviewID=inserted.ReviewID	;
END

IF EXISTS(SELECT * FROM DELETED) 
BEGIN
UPDATE Review
SET VotesNum=(SELECT COUNT(DISTINCT UsersVote.Vote) FROM UsersVote INNER JOIN DELETED 
	ON UsersVote.ReviewID=DELETED.ReviewID AND UsersVote.UsersID=DELETED.UsersID
	INNER JOIN [User] ON UsersVote.UsersID=[User].UsersID
WHERE UsersVote.ReviewID=Review.ReviewID  AND UsersVote.UsersID=[User].UsersID),


VotesPlus=(SELECT COUNT(DISTINCT UsersVote.Vote) FROM UsersVote INNER JOIN DELETED 
	ON UsersVote.ReviewID=DELETED.ReviewID AND UsersVote.UsersID=DELETED.UsersID
	INNER JOIN [User] ON UsersVote.UsersID=[User].UsersID
WHERE UsersVote.ReviewID=Review.ReviewID  AND UsersVote.UsersID=[User].UsersID AND UsersVote.Vote=1)

FROM Review INNER JOIN DELETED ON Review.ReviewID=DELETED.ReviewID WHERE Review.ReviewID=DELETED.ReviewID;	
END



END

GO

CREATE TRIGGER [dbo].[JobActorOrNotT]
ON Job
AFTER INSERT,UPDATE
AS

BEGIN

IF EXISTS(SELECT 1 FROM inserted WHERE JobsTitlesID IS NULL)
BEGIN
    RAISERROR ('Job title cannot be null', 16, 1)
    ROLLBACK TRANSACTION
    RETURN
END

IF EXISTS(SELECT 1 FROM inserted JOIN JobsTitle ON inserted.JobsTitlesID = JobsTitle.JobsID WHERE JobsTitle.JobsID IS NULL)
BEGIN
    RAISERROR ('Invalid job title', 16, 1)
    ROLLBACK TRANSACTION
    RETURN
END

IF EXISTS(SELECT 1 FROM inserted JOIN JobsTitle ON inserted.JobsTitlesID = JobsTitle.JobsID WHERE JobsTitle.JobsTitle = 'Actor' AND (inserted.StarOrNot IS NULL OR inserted.Role IS NULL))
BEGIN
    RAISERROR ('StarOrNot and Role values are required for Actor jobs', 16, 1)
    ROLLBACK TRANSACTION
    RETURN
END

IF EXISTS(SELECT 1 FROM inserted JOIN JobsTitle ON inserted.JobsTitlesID = JobsTitle.JobsID WHERE JobsTitle.JobsTitle <> 'Actor' AND (inserted.StarOrNot IS NOT NULL OR inserted.Role IS NOT NULL))
BEGIN
    RAISERROR ('You are not allowed to have values if you are not an actor', 16, 1)
    ROLLBACK TRANSACTION
    RETURN
END

END


GO
CREATE TRIGGER [dbo].[VideoNummI]
  ON [dbo].[Video] AFTER INSERT,UPDATE,DELETE
AS
BEGIN   
IF EXISTS(SELECT * FROM INSERTED) 
BEGIN		
	IF EXISTS(SELECT MovieID FROM INSERTED WHERE MovieID IS NOT NULL)
	BEGIN
	UPDATE Movie SET VideosNum=(SELECT COUNT(Video.MovieID)  From Video INNER JOIN inserted ON Video.MovieID=inserted.MovieID WHERE Video.MovieID=Movie.MoviesID GROUP BY Video.MovieID)	FROM Movie INNER JOIN inserted ON Movie.MoviesID=inserted.MovieID WHERE Movie.MoviesID=inserted.MovieID AND inserted.MovieID IS NOT NULL;
	END
	 IF EXISTS(SELECT SeriesID FROM INSERTED WHERE SeriesID IS NOT NULL)
	BEGIN
	UPDATE Series SET VideosNum=(SELECT COUNT(Video.SeriesID) FROM Video INNER JOIN inserted ON Video.SeriesID=inserted.SeriesID WHERE Video.SeriesID=Series.SeriesID GROUP BY Video.SeriesID)FROM Series INNER JOIN inserted ON Series.SeriesID=inserted.SeriesID WHERE Series.SeriesID=inserted.SeriesID AND inserted.SeriesID IS NOT NULL;
	END
END
IF EXISTS(SELECT * FROM DELETED) 
BEGIN		
	IF EXISTS(SELECT MovieID FROM DELETED WHERE MovieID IS NOT NULL)
	BEGIN
	UPDATE Movie SET VideosNum=(SELECT COUNT(Video.MovieID)  From Video INNER JOIN DELETED ON Video.MovieID=DELETED.MovieID WHERE Video.MovieID=Movie.MoviesID GROUP BY Video.SeriesID)	FROM Movie INNER JOIN DELETED ON Movie.MoviesID=DELETED.MovieID WHERE Movie.MoviesID=DELETED.MovieID AND DELETED.MovieID IS NOT NULL;
	END
	 IF EXISTS(SELECT SeriesID FROM DELETED WHERE SeriesID IS NOT NULL)
	BEGIN
	UPDATE Series SET VideosNum=(SELECT COUNT(Video.SeriesID) FROM Video INNER JOIN DELETED ON Video.SeriesID=DELETED.SeriesID WHERE Video.SeriesID=Series.SeriesID GROUP BY Video.SeriesID)FROM Series INNER JOIN DELETED ON Series.SeriesID=DELETED.SeriesID WHERE Series.SeriesID=DELETED.SeriesID AND DELETED.SeriesID IS NOT NULL;
	END
END

END
GO


CREATE TRIGGER [dbo].[AwardWinAndNom]
on [dbo].[Award] AFTER INSERT,UPDATE,DELETE
AS
BEGIN

IF EXISTS(SELECT * FROM INSERTED) 
BEGIN
		IF EXISTS(SELECT MoviesID FROM INSERTED WHERE MoviesID IS NOT NULL)
	BEGIN


	UPDATE Movie SET AwardNominNum=(SELECT COUNT(Award.MoviesID) FROM Award INNER JOIN inserted ON Award.MoviesID=inserted.MoviesID WHERE Award.WinnerOrNom=0 AND Award.MoviesID=Movie.MoviesID
	GROUP BY Award.MoviesID)FROM Movie INNER JOIN inserted ON Movie.MoviesID=inserted.MoviesID WHERE Movie.MoviesID=inserted.MoviesID AND inserted.MoviesID IS NOT NULL;

	UPDATE Movie SET AwardWinsNum=(SELECT COUNT(Award.MoviesID) FROM Award INNER JOIN inserted ON Award.MoviesID=inserted.MoviesID WHERE Award.WinnerOrNom=1 AND Award.MoviesID=Movie.MoviesID
	GROUP BY Award.MoviesID)FROM Movie INNER JOIN inserted ON Movie.MoviesID=inserted.MoviesID WHERE Movie.MoviesID=inserted.MoviesID AND inserted.MoviesID IS NOT NULL;

	END
	IF EXISTS(SELECT SeriesID FROM INSERTED WHERE SeriesID IS NOT NULL)
	BEGIN
	UPDATE Series SET AwardNominNum=(SELECT COUNT(Award.SeriesID) FROM Award INNER JOIN inserted ON Award.SeriesID=inserted.SeriesID WHERE Award.WinnerOrNom=0 AND Award.SeriesID=Series.SeriesID
	GROUP BY Award.SeriesID)FROM Series INNER JOIN inserted ON Series.SeriesID=inserted.SeriesID WHERE Series.SeriesID=inserted.SeriesID AND inserted.SeriesID IS NOT NULL;

	UPDATE Series SET AwardWinsNum=(SELECT COUNT(Award.SeriesID) FROM Award INNER JOIN inserted ON Award.SeriesID=inserted.SeriesID WHERE Award.WinnerOrNom=1 AND Award.SeriesID=Series.SeriesID
	GROUP BY Award.SeriesID)FROM Series INNER JOIN inserted ON Series.SeriesID=inserted.SeriesID WHERE Series.SeriesID=inserted.SeriesID AND inserted.SeriesID IS NOT NULL;
	END

END

IF EXISTS(SELECT * FROM DELETED) 
BEGIN
		IF EXISTS(SELECT MoviesID FROM DELETED WHERE MoviesID IS NOT NULL)
	BEGIN
	UPDATE Movie SET AwardNominNum=(SELECT COUNT(Award.MoviesID) FROM Award INNER JOIN DELETED ON Award.MoviesID=DELETED.MoviesID WHERE Award.WinnerOrNom=0 AND Award.MoviesID=Movie.MoviesID
	GROUP BY Award.MoviesID)FROM Movie INNER JOIN DELETED ON Movie.MoviesID=DELETED.MoviesID WHERE Movie.MoviesID=DELETED.MoviesID AND DELETED.MoviesID IS NOT NULL;
	UPDATE Movie SET AwardWinsNum=(SELECT COUNT(Award.MoviesID) FROM Award INNER JOIN DELETED ON Award.MoviesID=DELETED.MoviesID WHERE Award.WinnerOrNom=1 AND Award.MoviesID=Movie.MoviesID
	GROUP BY Award.MoviesID)FROM Movie INNER JOIN DELETED ON Movie.MoviesID=DELETED.MoviesID WHERE Movie.MoviesID=DELETED.MoviesID AND DELETED.MoviesID IS NOT NULL;

	END
	IF EXISTS(SELECT SeriesID FROM DELETED WHERE SeriesID IS NOT NULL)
	BEGIN
	UPDATE Series SET AwardNominNum=(SELECT COUNT(Award.SeriesID) FROM Award INNER JOIN DELETED ON Award.SeriesID=DELETED.SeriesID WHERE Award.WinnerOrNom=0 AND Award.SeriesID=Series.SeriesID
	GROUP BY Award.SeriesID)FROM Series INNER JOIN DELETED ON Series.SeriesID=DELETED.SeriesID WHERE Series.SeriesID=DELETED.SeriesID AND DELETED.SeriesID IS NOT NULL;

	UPDATE Series SET AwardWinsNum=(SELECT COUNT(Award.SeriesID) FROM Award INNER JOIN DELETED ON Award.SeriesID=DELETED.SeriesID WHERE Award.WinnerOrNom=1 AND Award.SeriesID=Series.SeriesID
	GROUP BY Award.SeriesID)FROM Series INNER JOIN DELETED ON Series.SeriesID=DELETED.SeriesID WHERE Series.SeriesID=DELETED.SeriesID AND DELETED.SeriesID IS NOT NULL;
	END

END

END



GO

CREATE TRIGGER [dbo].[UPDATEJOBSS]

ON [dbo].[Job]
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS(SELECT * FROM inserted) 
    BEGIN
        DECLARE @Top1Job INT, @Top2Job INT, @Top3Job INT;
        
        SELECT
            i.MemberOfCrewID,
            j.JobsTitlesID,
            COUNT(*) AS RatioJob,
            ROW_NUMBER() OVER (ORDER BY COUNT(j.JobsTitlesID) DESC) AS RowNumber
        INTO #customOne
        FROM
            inserted i
            INNER JOIN Job j ON i.MemberOfCrewID = j.MemberOfCrewID
            INNER JOIN MemberOfCrew mc ON j.MemberOfCrewID = mc.MemberOfCrewID
            INNER JOIN FilmCrew fc ON mc.FilmCrewID = fc.FilmCrewID
        WHERE
            fc.FilmCrewID IN (SELECT DISTINCT FilmCrewID FROM MemberOfCrew WHERE MemberOfCrewID = i.MemberOfCrewID)
        GROUP BY
            i.MemberOfCrewID,
            j.JobsTitlesID;

        ;WITH Top1 AS (SELECT JobsTitlesID FROM #customOne WHERE RowNumber = 1)
        SELECT @Top1Job = JobsTitlesID FROM Top1;

        ;WITH Top2 AS (SELECT JobsTitlesID FROM #customOne WHERE RowNumber = 2)
        SELECT @Top2Job = JobsTitlesID FROM Top2;

        ;WITH Top3 AS (SELECT JobsTitlesID FROM #customOne WHERE RowNumber = 3)
        SELECT @Top3Job = JobsTitlesID FROM Top3;
        
        UPDATE fc
        SET
            Top1Job = @Top1Job,
            Top2Job = @Top2Job,
            Top3Job = @Top3Job
        FROM
            FilmCrew fc
            INNER JOIN MemberOfCrew mc ON fc.FilmCrewID = mc.FilmCrewID
            INNER JOIN Job j ON mc.MemberOfCrewID = j.MemberOfCrewID
            INNER JOIN inserted i ON j.MemberOfCrewID = i.MemberOfCrewID
        WHERE
            fc.FilmCrewID IN (SELECT DISTINCT FilmCrewID FROM MemberOfCrew WHERE MemberOfCrewID = i.MemberOfCrewID);
    END
END;






GO
--//Update the date of the row that is modified.As for insert theres no need since theres default getdate

CREATE TRIGGER [dbo].[UpdatDateEEE]
ON [dbo].[Review] AFTER UPDATE
AS
BEGIN
UPDATE Review SET Date=GETDATE() FROM Review inner JOIN inserted ON Review.ReviewID=inserted.ReviewID WHERE Review.ReviewID=inserted.ReviewID
END


GO

CREATE TRIGGER [dbo].[UpdDate]
ON [dbo].[VoteForM] AFTER UPDATE
AS
BEGIN
UPDATE VoteForM SET VoteDate=GETDATE() FROM VoteForM INNER JOIN inserted 
ON VoteForM.MoviesID=inserted.MoviesID AND VoteForM.UsersID=inserted.UsersID WHERE VoteForM.MoviesID=inserted.MoviesID AND VoteForM.UsersID=inserted.UsersID;

END
GO

-- Updates the date in the VoteForS (ovies) because we need to compare it with the lastUpdate one.On insert there is default update date so no need)
CREATE TRIGGER UpddDate
ON [dbo].[VoteForS] AFTER UPDATE
AS
BEGIN
UPDATE VoteForM SET VoteDate=GETDATE() FROM VoteForS INNER JOIN inserted 
ON VoteForS.SeriesID=inserted.SeriesID AND VoteForS.UsersID=inserted.UsersID WHERE VoteForS.SeriesID=inserted.SeriesID AND VoteForS.UsersID=inserted.UsersID;

END

GO


ALTER TABLE VoteForS
ADD CONSTRAINT FK_VoteForSSeriesID	FOREIGN KEY(SeriesID)	REFERENCES  Series(SeriesID),
	CONSTRAINT FK_VoteForSUserID	FOREIGN KEY(UsersID) REFERENCES [User](UsersID)

ALTER TABLE VoteForM
ADD CONSTRAINT FK_VoteForMMoviesID	FOREIGN KEY(MoviesID)	REFERENCES  Movie(MoviesID),
	CONSTRAINT FK_VoteForMUserID	FOREIGN KEY(UsersID) REFERENCES [User](UsersID)

ALTER TABLE UsersVote
ADD CONSTRAINT FK_UsersVoteReviewID	FOREIGN KEY(ReviewID)	REFERENCES Review(ReviewID),
	CONSTRAINT FK_UsersVoteUserID	FOREIGN KEY(UsersID) REFERENCES [User](UsersID)

ALTER TABLE Review
ADD CONSTRAINT FK_ReviewMoviesID FOREIGN KEY(MoviesID)	REFERENCES  Movie(MoviesID),
	CONSTRAINT FK_ReviewUserID	FOREIGN KEY(UsersID) REFERENCES [User](UsersID),
	CONSTRAINT FK_ReviewSeriesID	FOREIGN KEY(SeriesID)	REFERENCES  Series(SeriesID)

ALTER TABLE Series
ADD CONSTRAINT FK_SeriesGenre1	FOREIGN KEY(Genre1)	REFERENCES  Genre(GenreID),
	CONSTRAINT FK_SeriesGenre2	FOREIGN KEY(Genre2)	REFERENCES  Genre(GenreID),
	CONSTRAINT FK_SeriesGenre3	FOREIGN KEY(Genre3)	REFERENCES  Genre(GenreID)

ALTER TABLE Movie
ADD CONSTRAINT FK_MovieGenre1	FOREIGN KEY(Genre1)	REFERENCES  Genre(GenreID),
	CONSTRAINT FK_MovieGenre2	FOREIGN KEY(Genre2)	REFERENCES  Genre(GenreID),
	CONSTRAINT FK_MovieGenre3	FOREIGN KEY(Genre3)	REFERENCES  Genre(GenreID)

ALTER TABLE Award
ADD CONSTRAINT FK_AwardSeriesID	FOREIGN KEY(SeriesID)	REFERENCES  Series(SeriesID),
	CONSTRAINT FK_AwardMoviesID FOREIGN KEY(MoviesID)	REFERENCES  Movie(MoviesID),
	CONSTRAINT FK_AwardFilmCrewID FOREIGN KEY(FilmCrewID) REFERENCES FilmCrew(FilmCrewID),
	CONSTRAINT FK_AwardAcademyAwardTitles FOREIGN KEY(AcademyAwardTitle) REFERENCES AcademyAwTitles(AcademyAwardID),
	CONSTRAINT FK_AwardGoldenGlobeTitles FOREIGN KEY(GoldenGlobeTitle) REFERENCES GoldenGlobeTitles(GoldenGlobeID)

ALTER TABLE PicOrVidURL
ADD CONSTRAINT FK_PicOrVidURLFilmCrewID FOREIGN KEY(FilmCrewID) REFERENCES FilmCrew(FilmCrewID)

ALTER TABLE MemberOfCrew
ADD CONSTRAINT FK_MemberOfCrewFilmCrewID FOREIGN KEY(FilmCrewID) REFERENCES FilmCrew(FilmCrewID),
	CONSTRAINT FK_MemberOfCrewSeriesID	FOREIGN KEY(SeriesID)	REFERENCES  Series(SeriesID),
	CONSTRAINT FK_MemberOfCrewMoviesID FOREIGN KEY(MoviesID)	REFERENCES  Movie(MoviesID)

ALTER TABLE Job
ADD CONSTRAINT FK_JobMemberOfCrewID	FOREIGN KEY(MemberOfCrewID)	REFERENCES  MemberOfCrew(MemberOfCrewID),
	CONSTRAINT FK_JobJobsTitlesID	FOREIGN KEY(JobsTitlesID) REFERENCES JobsTitle(JobsID)


ALTER TABLE Video
ADD CONSTRAINT FK_VideoSeriesID	FOREIGN KEY(SeriesID)	REFERENCES  Series(SeriesID),
	CONSTRAINT FK_VideoMoviesID	FOREIGN KEY(MovieID)	REFERENCES  Movie(MoviesID)

ALTER TABLE Image
ADD CONSTRAINT FK_ImageSeriesID	FOREIGN KEY(SeriesID)	REFERENCES  Series(SeriesID),
	CONSTRAINT FK_ImageMoviesID	FOREIGN KEY(MovieID)	REFERENCES  Movie(MoviesID)

ALTER TABLE Critic
ADD CONSTRAINT FK_CriticSeriesID	FOREIGN KEY(SeriesID)	REFERENCES  Series(SeriesID),
	CONSTRAINT FK_CriticMoviesID	FOREIGN KEY(MoviesID)	REFERENCES  Movie(MoviesID)

GO



DECLARE @SQL nvarchar(max)
DECLARE @DatabaseName nvarchar(max)

SET @DatabaseName = 'IMDb_YadaYada'

SET @SQL = ''
SELECT @SQL = @SQL + 'DBCC CHECKIDENT(''' + @DatabaseName + '.' + SCHEMA_NAME(schema_id) + '.' + name + ''', RESEED, 1); '
FROM sys.tables
WHERE OBJECTPROPERTY(OBJECT_ID(QUOTENAME(SCHEMA_NAME(schema_id)) + '.' + QUOTENAME(name)), 'TableHasIdentity') = 1

EXEC(@SQL)
GO



INSERT INTO LastUpdateVotes(LastUpdate) Values ( GETDATE() );

GO

INSERT INTO [User](FirstName,LastName,Password,Email) VALUES 
('Georgios','Kokkinos','123456789' ,'gkokkinos@gmail.com'),
('Argyro','Ververaki','123456789' ,'aververaki@gmail.com'),
('Ioannis','Balasis','123456789' ,'ibalasis@gmail.com'),
('Georgios','Ntomoras','123456789' ,'gntomoras@gmail.com'),
('Dimitrios','Iracleous','123456789' ,'diracleous@gmail.com');

GO

INSERT INTO FilmCrew(FirstName,LastName,BornLocation,BornDate,Description) VALUES
('Francis','Coppola','Detroit','1939/04/07','Francis Ford Coppola was born in 1939 in Detroit, Michigan, but grew up in a New York suburb in a creative, supportive Italian-American family. His father, Carmine Coppola, was a composer and musician. His mother, Italia Coppola (née Pennino), had been an actress. Francis Ford Coppola graduated with a degree in drama from Hofstra University, and did graduate work at UCLA in filmmaking'),
('Alfredo','James','Unknown','1940/04/25','Alfredo James "Al" Pacino established himself as a film actor during one of cinemas most vibrant decades, the 1970s, and has become an enduring and iconic figure in the world of American movies.He was born April 25, 1940 in Manhattan, New York City, to Italian-American parents, Rose (nee Gerardi) and Sal Pacino.'),
('James','Cann','Bronx(Germany)','1940/03/26','A masculine and enigmatic actor whose life and movie career have had more ups and downs than the average rollercoaster and whose selection of roles has arguably derailed him from achieving true superstar status, James Caan is New York-born and bred'),
('Emilia','Jones','Unknown','2002/02/23','Emilia Jones was recently named one of Varietys 10 Actors to Watch.She is best known for playing the lead role of Ruby Rossi in CODA which won the much coveted Best Picture Oscar in 2022.'),
('Kenneth','Charles','Unknown','1960/12/10','Kenneth Charles Branagh was born on December 10, 1960, in Belfast, Northern Ireland, to parents William Branagh, a plumber and carpenter, and Frances (Harper), both born in 1930. He has two siblings, William Branagh, Jr. (born 1955) and Joyce Branagh (born 1970).'),
('Jane','Campion','Wellington','1954/04/30','Jane Campion was born in Wellington, New Zealand, and now lives in Sydney, New South Wales, Australia. Having graduated with a BA in Anthropology from Victoria University of Wellington in 1975, and a BA, with a painting major, at Sydney College of the Arts in 1979...'),
('Maggie','Gyllenhaal','New York City','1977/11/16','Maggie Gyllenhaal was born on November 16, 1977 in New York City, New York as Margalit Ruth Gyllenhaal, the daughter of producer/screenwriter Naomi Foner and director Stephen Gyllenhaal, and the older sister of actor Jake Gyllenhaal. '),
('Bryan','Lee','California','1956/03/07','Bryan Lee Cranston was born on March 7, 1956 in Hollywood, California, to Audrey Peggy Sell, a radio actress, and Joe Cranston, an actor and former amateur boxer. His maternal grandparents were German, and his father was of Irish, German, and Austrian-Jewish ancestry.'),
('Albert','Ruddy','Unknown','1930/03/28','Albert Stotland Ruddy is a Canadian-American film and television producer. He is known for producing The Godfather (1972) and Million Dollar Baby (2004), both of which won him the Academy Award for Best Picture ')

GO

INSERT INTO FilmCrew(FirstName,LastName,BornLocation,DeathLocation,BornDate,DeathDate,Description) VALUES
('Marlon','Brando','Unknown','Unknown','1924/04/03','2004/07/01','Marlon Brando is widely considered the greatest movie actor of all time, rivaled only by the more theatrically oriented Laurence Olivier in terms of esteem. Unlike Olivier, who preferred the stage to the screen, Brando concentrated his talents on movies after bidding the Broadway stage adieu in 1949, a decision for which he was severely criticized when his star began to dim in the 1960s and he was excoriated for squandering his talents.');
GO

INSERT INTO Genre(GenreTitle) VALUES ('Crime'),('Drama'),('Comedy'),('Drama'),('Music'),('Thriller'),('Family'),('Mystery')

GO
INSERT INTO AcademyAwTitles(AcademyAwardTitle) VALUES 
('Best Picture'),
('Best Actor in a Leading Role'),
('Best Writing'),
('Best Actor in a Supporting Role'),
('Best Director');

GO
INSERT INTO GoldenGlobeTitles(GoldenGlobeTitle) VALUES 
('Best Director - Motion Picture'),
('Best Actor in a Motion Picture'),
('Best Original Score - Motion Picture'),
('Best Supporting Actor - Motion Picture'),
('Best Director - A TITLE HERE');
GO

INSERT INTO JobsTitle(JobsTitle) VALUES 
('Actor'), ('Director'),('Writer'),('Cinematographer'),('Producer')

GO

INSERT INTO Movie(Genre1,Genre2,Genre3,Duration,Description,ReleaseYear,ReleaseDate,TrailerURL,Title,CoverURL,Location,R) VALUES
(  1 ,2,NULL,'02:55:00','The aging patriarch of an organized crime dynasty in postwar New York City transfers control of his clandestine empire to his reluctant youngest son.','1972','1972/09/29','/video/vi1348706585/?playlistId=tt0068646&ref_=tt_ov_vi','The Godfather','/title/tt0068646/mediaviewer/rm746868224/?ref_=tt_ov_i','Sicily','R'),
(  3 ,2,5,'01:51:00','When the family s fishing business is threatened, Ruby finds herself torn between pursuing her passion at Berklee College of Music and her fear of abandoning her parents.','2021','2021/02/12','/video/vi3832463385/?playlistId=tt10366460&ref_=tt_ov_vi','CODA','/title/tt10366460/mediaviewer/rm759954177/?ref_=tt_ov_i','WhoKnows','PG-13'),
(  7 ,null,NULL,'02:41:00','An ancient prophecy seems to be coming true when a mysterious presence begins stalking the corridors of a school of magic and leaving its victims paralyzed.','2002','2002/04/30','/video/vi1705771289/?playlistId=tt0295297&ref_=tt_ov_vi','Harry Potter and the Chamber of Secrets','/title/tt0295297/mediaviewer/rm3790637825/?ref_=tt_ov_i','London','PG'),
(  3 ,7,NULL,'01:43:00','n eight-year-old troublemaker, mistakenly left home alone, must defend his home against a pair of burglars on Christmas eve.','1990','1990/02/22','/video/vi490651929/?playlistId=tt0099785&ref_=tt_ov_vi','Home Alone','/title/tt0099785/mediaviewer/rm3804584704/?ref_=tt_ov_i','New York','PG'),
(  3 ,1,NULL,'02:00:00','One year after Kevin McCallister was left home alone and had to defeat a pair of bumbling burglars, he accidentally finds himself stranded in New York City','1992','1992/09/29','/video/vi1197259545/?playlistId=tt0104431&ref_=tt_ov_vi','Home Alone 2','/title/tt0104431/mediaviewer/rm1832589056/?ref_=tt_ov_i','New York','PG')


GO
INSERT INTO Series(Genre1,Genre2,Genre3,Media,Duration,Description,Seasons,EpisodesNum,Years,Timespan,CoverURL,Title,TrailerURL,R) VALUES
(  3 ,7,NULL,'TV-Series','00:22:00','A gifted young teen tries to survive life with his dimwitted, dysfunctional family.',6, 151,6,'2000-2006','/title/tt0212671/mediaviewer/rm548231680/?ref_=tt_ov_i','Malcolm','/video/vi807320857/?playlistId=tt0212671&ref_=tt_ov_vi','TV-PG'),

(  1 ,2,6,'TV-Series','00:49:00','A chemistry teacher diagnosed with inoperable lung cancer turns to manufacturing and selling methamphetamine with a former student in order to secure his familys future.',5, 62,5,'2008-2013','/title/tt0903747/mediaviewer/rm3116305665/?ref_=tt_ov_i','Breaking Bad','/video/vi338798873/?playlistId=tt0903747&ref_=tt_ov_vi','TV-MA'),

(  1 ,4,8,'TV-Series','01:00:00','This series follows the Special Victims Unit, a specially trained squad of detectives in the New York City Police Department that investigate sexually related crimes.',24, 456,6,'1990-2022','/title/tt0203259/mediaviewer/rm2690971137/?ref_=tt_ov_i','Law&Order','/video/vi4106142489/?playlistId=tt0203259&ref_=tt_ov_vi','TV-14'),

(  3 ,NULL,NULL,'TV-Series','00:22:00','Follows the personal and professional lives of six twenty to thirty year-old friends living in the Manhattan borough of New York City.',10, 234,11,'1994-2004','/title/tt0108778/mediaviewer/rm2513109504/?ref_=tt_ov_i','Friends','/video/vi4240746009/?playlistId=tt0108778&ref_=tt_ov_vi','TV-14'),

(  3 ,7,NULL,'TV-Series','00:22:00','After being fired from her job and dumped by her boyfriend, a cosmetics saleswoman becomes the nanny to the three children of a rich English widower.',6, 145,7,'1993-1999','/title/tt0106080/mediaviewer/rm3099066368/?ref_=tt_ov_i','The Nanny','/video/vi646495513/?playlistId=tt0106080&ref_=tt_ov_vi','TV-PG')
GO

INSERT INTO Critic(MoviesID,SeriesID,URL) VALUES
(1,NULL,'https://www.nytimes.com/1972/03/12/archives/bravo-brandos-godfather-brandos-godfather.html'),
(null,1,'https://www.metacritic.com/tv/malcolm-in-the-middle'),
(4,NULL,'https://www.bbc.co.uk/films/2000/12/04/home_alone_1990_review.shtml'),
(5,NULL,'https://armchaircinema.com/home-alone-2-lost-in-new-york/'),
(NULL,2,'https://www.nytimes.com/2008/01/18/arts/television/18brea.html')

GO

INSERT INTO MemberOfCrew(FilmCrewID,SeriesID,MoviesID,MoviesOrSeries) VALUES
(1,null,1,'Movie'),
(2,NULL,1,'Movie'),
(3,2,NULL,'Series'),
(4,1,NULL,'Series'),
(5,null,2,'Movie')

GO
INSERT INTO JOB(MemberOfCrewID,JobsTitlesID,Description,StarOrNot,Role) VALUES
(1,1,'Rest In peace',1,'BadAss'),
(2,1,'In the godfather too..need to check out this movie',1,'Mafia something'),
(3,1,'He broke it bad',1,'prisoner'),
(4,1,'yada yada yada',1,'hero'),
(5,1,'she won something',1,'SecretRole')

GO

INSERT INTO VoteForM(MoviesID,UsersID,Vote) VALUES
(1,1,10),
(1,2,9),
(5,3,9),
(4,4,8),
(2,3,5),
(3,2,8)

GO

INSERT INTO VoteFors(SeriesID,UsersID,Vote) VALUES
(1,1,10),
(1,2,9),
(5,3,9),
(4,4,8),
(2,3,5),
(3,2,8)

GO

INSERT INTO Image([SeriesID], [MovieID], [URL], [Info]) VALUES
(NULL ,1,'/testUrl.png','TestInfo'),
(NULL ,2,'/testUrl.png','TestInfo'),
(NULL ,3,'/testUrl.png','TestInfo'),
(NULL ,4,'/testUrl.png','TestInfo'),
(NULL ,5,'/testUrl.png','TestInfo'),
(1,NULL,'/testUrl.png','TestInfo'),
(2,NULL,'/testUrl.png','TestInfo'),
(3,NULL,'/testUrl.png','TestInfo'),
(4,NULL,'/testUrl.png','TestInfo'),
(5,NULL,'/testUrl.png','TestInfo');
GO

INSERT INTO Video([SeriesID], [MovieID], [URL], [Info]) VALUES
(NULL ,1,'/testUrl.mp4','TestInfo'),
(NULL ,2,'/testUrl.mp4','TestInfo'),
(NULL ,3,'/testUrl.mp4','TestInfo'),
(NULL ,4,'/testUrl.mp4','TestInfo'),
(NULL ,5,'/testUrl.mp4','TestInfo'),
(1,NULL,'/testUrl.mp4','TestInfo'),
(2,NULL,'/testUrl.mp4','TestInfo'),
(3,NULL,'/testUrl.mp4','TestInfo'),
(4,NULL,'/testUrl.mp4','TestInfo'),
(5,NULL,'/testUrl.mp4','TestInfo');
GO
INSERT INTO Review([UsersID], [SeriesID], [MoviesID], [Spoiler],[Header], [Body]) VALUES
(1 ,NULL,1 ,1,'TitleTest','BodyTest'),
(2 ,NULL,2 ,1,'TitleTest','BodyTest'),
(3 ,NULL,3 ,1,'TitleTest','BodyTest'),
(4 ,NULL,4 ,1,'TitleTest','BodyTest'),
(5 ,NULL,5 ,1,'TitleTest','BodyTest'),
(1 ,1,NULL ,1,'TitleTest','BodyTest'),
(2 ,2,NULL ,1,'TitleTest','BodyTest'),
(3 ,3,NULL ,1,'TitleTest','BodyTest'),
(4 ,4,NULL ,1,'TitleTest','BodyTest'),
(5 ,5,NULL ,1,'TitleTest','BodyTest')

GO
INSERT INTO UsersVote([UsersID], [ReviewID], [Vote]) VALUES
(1,1,1),
(1,2,1),
(1,3,1),
(2,4,1),
(1,5,1),
(3,2,1),
(5,1,1)

GO
INSERT INTO[dbo].[PicOrVidURL]( [FilmCrewID], [URL], [IsItPicOrVid], [Comment]) VALUES
								( 1,'/TESTurl',0,'TestComment'),
								( 1,'/TESTurl',1,'TestComment'),
								( 2,'/TESTurl',0,'TestComment'),
								( 2,'/TESTurl',1,'TestComment'),
								( 3,'/TESTurl',0,'TestComment'),
								( 3,'/TESTurl',1,'TestComment'),
								( 4,'/TESTurl',0,'TestComment'),
								( 4,'/TESTurl',1,'TestComment'),
								( 5,'/TESTurl',0,'TestComment'),
								( 5,'/TESTurl',1,'TestComment')
GO
INSERT INTO[dbo].[Award]([SeriesID], [MoviesID], [FilmCrewID], [AcademyAward], [GoldenGlobe], [AcademyAwardTitle], [GoldenGlobeTitle], [WinnerOrNom], [Date], [Location], [Comment], [OscarOrGolden]) VALUES
						(NULL,1, 5 , NULL , 1 ,NULL,1 , 0 ,'2022/06/30','USA','CommentTest','Golden Globe'),
						(NULL,2, 4 , NULL , 1 ,NULL,1 , 0 ,'2022/06/30','USA','CommentTest','Golden Globe'),
						(NULL,3, 3 , NULL , 1 ,NULL,1 , 1 ,'2022/06/30','USA','CommentTest','Golden Globe'),
						(NULL,4, 2 , NULL , 1 ,NULL,1 , 0 ,'2022/06/30','USA','CommentTest','Golden Globe'),
						(NULL,5, 1 , NULL , 1 ,NULL,1 , 0 ,'2022/06/30','USA','CommentTest','Golden Globe'),
						(1,NULL,5 , 1 , NULL ,1 , null,0 ,'2022/02/15','GERMANY','CommentTest','Oscar'),
						(2,NULL,4 , 1 , NULL ,1 , null,0 ,'2022/02/15','GERMANY','CommentTest','Oscar'),
						(3,NULL,3 , 1 , NULL ,1 , null,1 ,'2022/02/15','GERMANY','CommentTest','Oscar'),
						(4,NULL,2 , 1 , NULL ,1 , null,0 ,'2022/02/15','GERMANY','CommentTest','Oscar'),
						(5,NULL,1 , 1 , NULL ,1 , null,0 ,'2022/02/15','GERMANY','CommentTest','Oscar'),
						(3,NULL,3 , 1 , NULL ,1 , null,0 ,'2022/02/15','GERMANY','CommentTest','Oscar')