/*************************************************************************************************************
ObjectName          : Stored Procedure [UpdateAllUserList]
Description			: Update all user in a table
Creator Name		: Dibyendu Nandi
Creation Date		: 10/11/2018
Approved By			:
Approved Date		: 
Modified By			:sdsdsd
Modification Date	:
Modification Reason : 
*************************************************************************************************************/
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[UpdateAllUserList]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[UpdateAllUserList]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE UpdateAllUserList
@XML_USERLIST XML --'<Users><AllUserList><UserId>5001</UserId><LoginId>ksts</LoginId><SiteName>http://192.168.2.195/Kovair8.7.5</SiteName></AllUserList><AllUserList><UserId>5004</UserId><LoginId>DChang64271</LoginId><SiteName>http://192.168.2.195/Kovair8.7.5</SiteName></AllUserList><AllUserList><UserId>5006</UserId><LoginId>SKalavar109380</LoginId><SiteName>http://192.168.2.195/Kovair8.7.5</SiteName></AllUserList><AllUserList><UserId>5008</UserId><LoginId>SMeduri104032</LoginId><SiteName>http://192.168.2.195/Kovair8.7.5</SiteName></AllUserList><AllUserList><UserId>5012</UserId><LoginId>tcepoc</LoginId><SiteName>http://192.168.2.195/Kovair8.7.5</SiteName></AllUserList><AllUserList><UserId>5035</UserId><LoginId>HSingh115982</LoginId><SiteName>http://192.168.2.195/Kovair8.7.5</SiteName></AllUserList><AllUserList><UserId>5042</UserId><LoginId>DBhat111452</LoginId><SiteName>http://192.168.2.195/Kovair8.7.5</SiteName></AllUserList></Users>'

AS

BEGIN
	SET NOCOUNT ON
	DECLARE @STR_SiteName NVARCHAR(512),
			@DT_LastSyncTime  DATETIME

	SELECT @STR_SiteName = UserList.Col.value('SiteName[1]', 'NVARCHAR(512)'),@DT_LastSyncTime = UserList.Col.value('SyncTime[1]', 'DATETIME') FROM @XML_USERLIST.nodes('.//Root') UserList(Col) 

	DELETE FROM tAUL FROM tAllUserList tAUL 
	INNER JOIN  @XML_USERLIST.nodes('.//Root/AllUserList') UserList(Col) ON UserList.Col.value('UserId[1]', 'INT') = tAUL.UserID AND tAUL.SiteName =  @STR_SiteName
	WHERE UserList.Col.value('RecordStatus[1]', 'CHAR(1)') <> 'A'

	INSERT INTO tAllUserList(UserID,LoginId,SiteName,IsActiveDirectoryUser,LastSyncTime)
		SELECT UserList.Col.value('UserId[1]', 'INT') UserID,
		UserList.Col.value('LoginId[1]', 'NVARCHAR(512)') LoginId,
		@STR_SiteName,
		UserList.Col.value('IsActiveDirectoryUser[1]', 'CHAR(1)') IsActiveDirectoryUser,
		@DT_LastSyncTime
		FROM @XML_USERLIST.nodes('.//Root/AllUserList') UserList(Col) 
		LEFT JOIN tAllUserList tAUL ON tAUL.UserID = UserList.Col.value('UserId[1]', 'INT') AND tAUL.SiteName = @STR_SiteName
		WHERE tAUL.UserID IS NULL AND UserList.Col.value('RecordStatus[1]', 'CHAR(1)') = 'A'

	SET NOCOUNT OFF
END
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO




 
