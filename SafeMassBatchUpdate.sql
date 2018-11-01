/***
Batched updates to huge person table
***/
CREATE TABLE #records2update (person_id uniqueidentifier not null primary key, updated bit not null default 0, record_id int identity)

INSERT INTO #records2update (person_id) SELECT person_id FROM person WHERE ethnicity != '' OR ethnicity IS NULL

declare @ctr int, @limit int, @set_limit int, @set_ctr int

SELECT @limit = COUNT(*) FROM #records2update
SET @ctr = @limit
SELECT @ctr

WHILE @ctr > 0
BEGIN
	
		BEGIN TRAN
		
		UPDATE person SET ethnicity = ''
		WHERE person_id IN
		(SELECT TOP 1000 person_id FROM #records2update WHERE updated = 0 ORDER BY record_id)
		
		IF @@ERROR != 0 
		BEGIN
			ROLLBACK TRAN
		END
		ELSE
		BEGIN
		UPDATE #records2update SET updated = 1 WHERE person_id IN
		(SELECT TOP 1000 person_id FROM #records2update WHERE updated = 0 ORDER BY record_id)
		IF @ctr > 999 SET @ctr = @ctr - 1000 ELSE SET @ctr = 0
		COMMIT TRAN
		END
END