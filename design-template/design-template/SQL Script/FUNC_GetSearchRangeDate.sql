USE [ChurchKiosk]
GO
/****** Object:  UserDefinedFunction [dbo].[FUNC_GetSearchRangeDate]    Script Date: 15/6/2018 9:37:33 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Navneet Chaudhary>
-- Create date: <10 Jun 2018>
-- Description:	<To reset daily recurring date-filter>
-- =============================================
ALTER FUNCTION [dbo].[FUNC_GetSearchRangeDate](@CalStartDate DATETIME, @CalEndDate DATETIME, @EventDateTime DATETIME, @Interval INT)  
RETURNS DATETIME   
AS   
-- Returns the stock level for the product.  
BEGIN  
    DECLARE @NewEventDate DATETIME;
	DECLARE @DayDiff INT;

	IF @CalStartDate > @EventDateTime
	BEGIN
		SET @DayDiff = (SELECT DATEDIFF(DAY, @EventDateTime, @CalStartDate))
		IF (@DayDiff % @Interval) = 0
		BEGIN
			SET @NewEventDate = @CalStartDate
		END
		ELSE
		BEGIN
			SET @CalStartDate = DATEADD(DD, -1, @CalStartDate)
			WHILE (SELECT DATEDIFF(DAY, @EventDateTime, @CalStartDate)) % @Interval <> 0
			BEGIN
				SET @CalStartDate = DATEADD(DD, -1, @CalStartDate)
			END
			SET @NewEventDate = @CalStartDate
		END
	END
	ELSE IF @EventDateTime BETWEEN @CalStartDate AND @CalEndDate
	BEGIN
		SET @NewEventDate = @EventDateTime
	END

    RETURN @NewEventDate;  
END;
