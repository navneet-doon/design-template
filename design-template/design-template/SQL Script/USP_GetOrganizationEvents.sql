USE [ChurchKiosk]
GO
/****** Object:  StoredProcedure [dbo].[USP_GetOrganizationEvents]    Script Date: 15/6/2018 9:35:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Navneet Chaudhary>
-- Create date: <23 Jul 2017>
-- Description:	<To fetch organization events from given range of start & end date>
-- =============================================
ALTER PROCEDURE [dbo].[USP_GetOrganizationEvents]
	-- Add the parameters for the stored procedure here
	@StartDate AS DATETIME, 
	@EndDate AS DATETIME, 
	@OrganizationId BIGINT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    DECLARE @TblEvents TABLE(
		[EventId] BIGINT,
		[RecurringEventUniqueId] UNIQUEIDENTIFIER,
		[EventName] NVARCHAR(100),
		[Description] NVARCHAR(1000),
		[Venue] NVARCHAR(100),
		[ParticipantLimit] INT,
		[ParticipantCount] INT,
		[EventCost] INT,
		[StartDateTime] DATETIME,
		[EndDateTime] DATETIME,
		[TimezoneOffSet] INT,
		[WeekRangeStartDateTime] DATETIME,
		[WeekRangeEndDateTime] DATETIME,
		[EventImage] VARCHAR(50),
		[AllDay] BIT,
		[IsRecurring] BIT,
		[RecurringType] INT,
		[RecurringEventStartDate] DATETIME,
		[RepeatInterval] INT,
		[DaysInWeek] VARCHAR(20),
		[RepeatEndDate] DATETIME
	);
	---------------------------------------- Insert non-recurring events into table variable -----------------------------------------
	INSERT INTO @TblEvents
	SELECT EventId, RecurringEventUniqueId, EventName, [Description], Venue, ParticipantLimit, ParticipantCount, EventCost, StartDateTime, EndDateTime, TimezoneOffSet, StartDateTime, EndDateTime, EventImage, AllDay, IsRecurring, RecurringType, NULL, NULL, NULL, NULL 
	FROM [Events] 
	WHERE OrganizationId = @OrganizationId 
	AND EndDateTime BETWEEN @StartDate AND @EndDate 
	AND RecurringType = 0

	-----------------------------------------Declare cursor columns -----------------------------------------
	DECLARE @EventId BIGINT
	DECLARE @RecurringEventUniqueId UNIQUEIDENTIFIER
	DECLARE @EventName NVARCHAR(100)
	DECLARE @Description NVARCHAR(1000)
	DECLARE @Venue NVARCHAR(100)
	DECLARE @ParticipantLimit INT
	DECLARE @ParticipantCount INT
	DECLARE @EventCost INT
	DECLARE @StartDateTime DATETIME
	DECLARE @EndDateTime DATETIME
	DECLARE @TimezoneOffSet INT
	DECLARE @EventImage VARCHAR(50)
	DECLARE @AllDay BIT
	DECLARE @IsRecurring BIT
	DECLARE @RecurringType INT
	DECLARE @RepeatInterval INT
	DECLARE @DaysInWeek VARCHAR(20)
	DECLARE @RepeatEndDate DATETIME

	---------------------------------------- Reset recurring event search start date -----------------------------------------
	DECLARE @EventSearchStartDateTime DATETIME
	DECLARE @EventSearchEndDateTime DATETIME

	---------------------------------------- Declare Cursor -----------------------------------------
	DECLARE Event_Cursor CURSOR FOR  
	(
		SELECT TB1.EventId, TB1.RecurringEventUniqueId, TB1.EventName, TB1.[Description], TB1.Venue, TB1.ParticipantLimit, TB1.ParticipantCount, TB1.EventCost, TB1.StartDateTime, TB1.EndDateTime, TB1.TimezoneOffSet, TB1.EventImage, TB1.AllDay, TB1.IsRecurring, TB1.RecurringType, TB2.RepeatInterval, TB2.DaysInWeek, TB2.RepeatEndDate 
		FROM [Events] TB1 LEFT JOIN RecurringEvents TB2 
		ON TB1.EventId = TB2.EventId 
		WHERE TB1.OrganizationId = @OrganizationId 
		AND (TB1.EndDateTime BETWEEN @StartDate AND @EndDate)
		AND TB1.RecurringType <> 0
		UNION
		SELECT TB1.EventId, TB1.RecurringEventUniqueId, TB1.EventName, TB1.[Description], TB1.Venue, TB1.ParticipantLimit, TB1.ParticipantCount, TB1.EventCost, TB1.StartDateTime, TB1.EndDateTime, TB1.TimezoneOffSet, TB1.EventImage, TB1.AllDay, TB1.IsRecurring, TB1.RecurringType, TB2.RepeatInterval, TB2.DaysInWeek, TB2.RepeatEndDate 
		FROM [Events] TB1 LEFT JOIN RecurringEvents TB2 
		ON TB1.EventId = TB2.EventId 
		WHERE TB1.OrganizationId = @OrganizationId 
		AND (TB2.RepeatEndDate IS NULL OR (TB1.EndDateTime < TB2.RepeatEndDate AND TB2.RepeatEndDate > @StartDate))
		AND TB1.StartDateTime <= @EndDate
		AND TB1.RecurringType <> 0
	)

	OPEN Event_Cursor
	FETCH NEXT FROM Event_Cursor INTO @EventId, @RecurringEventUniqueId, @EventName, @Description, @Venue, @ParticipantLimit, @ParticipantCount, @EventCost, @StartDateTime, @EndDateTime, @TimezoneOffSet, @EventImage, @AllDay, @IsRecurring, @RecurringType, @RepeatInterval, @DaysInWeek, @RepeatEndDate

	WHILE @@FETCH_STATUS = 0
	BEGIN

	   IF @RecurringType = 1
	   BEGIN
			--****************************** To reset daily recurring date filters (starts) ***********************************************
			SET @EventSearchStartDateTime = dbo.FUNC_GetSearchRangeDate(@StartDate, @EndDate, @StartDateTime, @RepeatInterval) + CAST(CAST(@StartDateTime AS TIME) AS DATETIME)
			SET @EventSearchEndDateTime = dbo.FUNC_GetSearchRangeDate(@StartDate, @EndDate, @StartDateTime, @RepeatInterval) + CAST(CAST(@EndDateTime AS TIME) AS DATETIME)
			--****************************** To reset daily recurring date filters (ends) *************************************************

			DECLARE @CurrentDailyEventEndDate DATETIME
			SET @CurrentDailyEventEndDate = @EventSearchEndDateTime
			--SET @CurrentDailyEventEndDate = @EndDateTime

			DECLARE @DailyEventStartTime DATETIME
			SET @DailyEventStartTime = @EventSearchStartDateTime
			--SET @DailyEventStartTime = @StartDateTime

			DECLARE @DailyEventEndTime DATETIME
			SET @DailyEventEndTime = @EventSearchEndDateTime
			--SET @DailyEventEndTime = @EndDateTime

			DECLARE @DailyRecurringEventStartDate DATETIME
			SET @DailyRecurringEventStartDate = @EventSearchStartDateTime
			--SET @DailyRecurringEventStartDate = @StartDateTime

			WHILE (@CurrentDailyEventEndDate <= @EndDate AND (@CurrentDailyEventEndDate <= @RepeatEndDate OR @RepeatEndDate IS NULL))
			BEGIN
				INSERT INTO @TblEvents VALUES(@EventId, @RecurringEventUniqueId, @EventName, @Description, @Venue, @ParticipantLimit, @ParticipantCount, @EventCost,
				@DailyEventStartTime, @DailyEventEndTime, @TimezoneOffSet, @DailyEventStartTime, @DailyEventEndTime, @EventImage, @AllDay, @IsRecurring, @RecurringType, @DailyRecurringEventStartDate, @RepeatInterval, @DaysInWeek, @RepeatEndDate)
				SET @CurrentDailyEventEndDate = @CurrentDailyEventEndDate + @RepeatInterval
				SET @DailyEventStartTime = @DailyEventStartTime + @RepeatInterval
				SET @DailyEventEndTime = @DailyEventEndTime + @RepeatInterval
			END
	   END

	   IF @RecurringType = 2
	   BEGIN
			--****************************** To reset weekly recurring date filters (starts) ***********************************************
			SET @EventSearchStartDateTime = DATEADD(WW, DATEDIFF(WW, 0, @StartDate), 0) + CAST(CAST(@StartDateTime AS TIME) AS DATETIME)
			SET @EventSearchEndDateTime = DATEADD(WW, DATEDIFF(WW, 0, @StartDate), 0) + CAST(CAST(@EndDateTime AS TIME) AS DATETIME)
			--****************************** To reset weekly recurring date filters (ends) *************************************************

			DECLARE @CurrentWeeklyEventEndDate DATETIME
			SET @CurrentWeeklyEventEndDate = @EventSearchEndDateTime
			
			DECLARE @WeekRangeStartDate DATETIME
			SET @WeekRangeStartDate = @EventSearchStartDateTime

			DECLARE @WeeklyEventStartTime DATETIME
			SET @WeeklyEventStartTime = DATEADD(DD, CAST(SUBSTRING(@DaysInWeek ,1, 1) AS INT)-1, @EventSearchStartDateTime)
			--SET @WeeklyEventStartTime = @StartDateTime
			
			DECLARE @WeeklyEventEndTime DATETIME
			SET @WeeklyEventEndTime = DATEADD(DD, CAST(SUBSTRING(@DaysInWeek ,1, 1) AS INT)-1, @EventSearchEndDateTime)
			--SET @WeeklyEventEndTime = @EndDateTime

			DECLARE @WeeklyRecurringEventStartDate DATETIME
			SET @WeeklyRecurringEventStartDate = @StartDateTime
			
			--PRINT @CurrentWeeklyEventEndDate
			--PRINT @EndDate
			WHILE (@CurrentWeeklyEventEndDate <= @EndDate AND (@CurrentWeeklyEventEndDate <= @RepeatEndDate OR @RepeatEndDate IS NULL))
			BEGIN
				IF @CurrentWeeklyEventEndDate >= @StartDateTime OR ((SELECT DATEPART(WK, @CurrentWeeklyEventEndDate)) = (SELECT DATEPART(WK, @StartDateTime)) AND (SELECT DATEPART(YY, @CurrentWeeklyEventEndDate)) = (SELECT DATEPART(YY, @StartDateTime)))
				BEGIN
					INSERT INTO @TblEvents VALUES(@EventId, @RecurringEventUniqueId, @EventName, @Description, @Venue, @ParticipantLimit, @ParticipantCount, @EventCost,
					@WeeklyEventStartTime, @WeeklyEventEndTime, @TimezoneOffSet, @WeekRangeStartDate, @WeekRangeStartDate + (@RepeatInterval * 6),
					@EventImage, @AllDay, @IsRecurring, @RecurringType, @WeeklyRecurringEventStartDate, @RepeatInterval, @DaysInWeek, 
					(CASE WHEN (SELECT COUNT(*) FROM RecurringEvents WHERE EventId IN(SELECT EventId FROM [Events] WHERE RecurringEventUniqueId = @RecurringEventUniqueId) AND RepeatEndDate IS NULL) > 0 THEN NULL ELSE (SELECT MAX(RepeatEndDate) FROM RecurringEvents WHERE EventId IN(SELECT EventId FROM [Events] WHERE RecurringEventUniqueId = @RecurringEventUniqueId)) END)
				)
				END

				SET @CurrentWeeklyEventEndDate = @CurrentWeeklyEventEndDate + (@RepeatInterval * 7)
				SET @WeeklyEventStartTime = @WeeklyEventStartTime + (@RepeatInterval * 7)
				SET @WeeklyEventEndTime = @WeeklyEventEndTime + (@RepeatInterval * 7)
				SET @WeekRangeStartDate = @WeekRangeStartDate + (@RepeatInterval * 7)
			END
	   END

	   IF @RecurringType = 3
	   BEGIN
			DECLARE @CurrentMonthlyEventEndDate DATETIME
			SET @CurrentMonthlyEventEndDate = @EndDateTime
			DECLARE @MonthlyEventStartTime DATETIME
			SET @MonthlyEventStartTime = @StartDateTime
			DECLARE @MonthlyEventEndTime DATETIME
			SET @MonthlyEventEndTime = @EndDateTime
			DECLARE @MonthlyRecurringEventStartDate DATETIME
			SET @MonthlyRecurringEventStartDate = @StartDateTime
			WHILE (@CurrentMonthlyEventEndDate <= @EndDate AND (@CurrentMonthlyEventEndDate <= @RepeatEndDate OR @RepeatEndDate IS NULL))
			BEGIN
				INSERT INTO @TblEvents VALUES(@EventId, @RecurringEventUniqueId, @EventName, @Description, @Venue, @ParticipantLimit, @ParticipantCount, @EventCost,
				@MonthlyEventStartTime, @MonthlyEventEndTime, @TimezoneOffSet, @MonthlyEventStartTime, @MonthlyEventEndTime,
				@EventImage, @AllDay, @IsRecurring, @RecurringType, @MonthlyRecurringEventStartDate, @RepeatInterval, @DaysInWeek, @RepeatEndDate)

				SET @CurrentMonthlyEventEndDate = DATEADD(M, @RepeatInterval, @CurrentMonthlyEventEndDate)
				SET @MonthlyEventStartTime = DATEADD(M, @RepeatInterval, @MonthlyEventStartTime)
				SET @MonthlyEventEndTime = DATEADD(M, @RepeatInterval, @MonthlyEventEndTime)
			END
	   END

       FETCH NEXT FROM Event_Cursor INTO @EventId, @RecurringEventUniqueId, @EventName, @Description, @Venue, @ParticipantLimit, @ParticipantCount, @EventCost, @StartDateTime, @EndDateTime, @TimezoneOffSet, @EventImage, @AllDay, @IsRecurring, @RecurringType, @RepeatInterval, @DaysInWeek, @RepeatEndDate   
	END
	CLOSE Event_Cursor   
	DEALLOCATE Event_Cursor

	SELECT * FROM @TblEvents
	
	--SELECT EventId,	
	--	RecurringEventUniqueId,	
	--	EventName,	
	--	[Description],	
	--	Venue,	
	--	ParticipantLimit,	
	--	ParticipantCount,
	--	EventCost,	
	--	StartDateTime,	
	--	EndDateTime,
	--	TimezoneOffSet,	
	--	CAST(NULL AS DATETIME) AS WeekRangeStartDateTime,	
	--	CAST(NULL AS DATETIME) AS WeekRangeEndDateTime,	
	--	EventImage,	
	--	AllDay,	
	--	IsRecurring,	
	--	RecurringType,
	--	CAST(NULL AS DATETIME) AS RecurringEventStartDate,	
	--	CAST(NULL AS INT) AS RepeatInterval,	
	--	CAST(NULL AS VARCHAR(20)) AS DaysInWeek,	
	--	CAST(NULL AS DATETIME) AS RepeatEndDate
	--FROM [Events]
END

