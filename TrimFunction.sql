
CREATE FUNCTION [dbo].[Trim]
/**
summary:   >
This procedure returns a string with all leading and trailing blank space removed. It is similar to the TRIM functions in most current computer languages. You can change the value of the string assigned to @BlankRange, which is then used by the PATINDEX function. The string can be a rangee.g. a-g or a list of characters such as abcdefg.

Author: Phil Factor
Revision: 1.1 changed list of control character to neater range.
date: 28 Jan 2011
example:
     - code: dbo.Trim('  678ABC   ')
     - code: dbo.Trim('  This has leading and trailing spaces  ')
     - code: dbo.Trim('  left-Trim This')
     - code: dbo.Trim('Right-Trim This      ')
returns:   >
Input string without trailing or leading blank characters, however these characters are defined in @BlankRange

**/ (@String VARCHAR(MAX))
RETURNS VARCHAR(MAX)
AS
BEGIN
  DECLARE @BlankRange CHAR(255),
    @FirstNonBlank INT,
    @LastNonBlank INT
  IF @String IS NULL
    RETURN NULL--filter out null strings
  SELECT  @BlankRange = CHAR(0) + '- ' + CHAR(160)
  /* here is where you set your definition of what constitutes a blank character. We've just chosen every 'control' character, the space character and the non-breaking space. Your requirements could be different!*/
  SELECT  @FirstNonBlank = PATINDEX('%[^' + @BlankRange + ']%', @String)
  SELECT  @lastNonBlank = 1 + LEN(@String + '|') - (PATINDEX('%[^' + @BlankRange + ']%',
                                                             REVERSE(@String)))
  IF @FirstNonBlank > 0
    RETURN SUBSTRING(@String,@FirstNonBlank, @LastNonBlank-@firstNonBlank)
  RETURN '' --nothing would be left    
END
GO


