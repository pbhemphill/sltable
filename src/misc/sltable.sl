% The ISISscripts are a prerequisite
% (technically, sltable is _part_ of the ISISscripts)
#ifnexists TeX_value_pm_error
require("isisscripts");
#endif

% This determines which type of table we're creating.
% "tabular" -> make a standard LaTeX table
% "deluxetable" -> table using the deluxetable LaTeX package
private variable sltableType = "tabular";

% end-of-line command
private define sltableEOL() {
  return "\n";
}

% Keeping track of indentation
% This really just makes the TeX code a bit prettier, but it's nice to have
private variable sltableNTabs = 0;
private define sltableTabs() {
  variable i;
  variable t = "";
  if(sltableNTabs > 0) {
    _for i (0,sltableNTabs-1,1) {
      t += "  ";
    }
  }
  return t;
}

%%%%%%%%%%%%%%%%%%%%%%%%
% sltableSetType
%
% SYNOPSIS
%   Defines output of subsequent function calls.
%
% USAGE
%   table_set_type(String_Type newTableType);
%
% DESCRIPTION
%   This function sets the internal "sltableType" variable, which is checked by
%   the other functions in this package to determine what type of LaTeX code
%   they output. E.g., sltableNoteMark("*") will output "\tablenotemark{*}"
%   command if sltableType == "deluxetable", but will output "$^{\text{*}}$" if
%   sltableType == "tabular".
%
% INPUTS
%   String_Type newTableType: type of tables to be generated by subsequent
%     commands. Must be either "deluxetable" or "tabular".
%
% OUTPUTS
%   This function produces no output.
%
% SEE ALSO
%   table_get_type
%%%%%%%%%%%%%%%%%%%%%%%%
private define sltableSetType() {
  variable newTableType;
  (newTableType) = ();
  if( _NARGS != 1 || 
      typeof(newTableType) != String_Type ||
      (sltableType != "deluxetable" and sltableType != "tabular")
    ) {
    usage("sltableSetType(String_Type sltableType)");
    throw InvalidParmError;
  }
  sltableType = newTableType;
}
%%%%%%%%%%%%%%%%%%%%%%%%
% sltableGetType
%
% SYNOPSIS
%   Returns the current table type
%
% USAGE
%   String_Type curTableType = table_get_type()
%
% DESCRIPTION
%   Returns the current value of the internal "sltableType" variable.
%
% INPUTS
%   No inputs
%
% OUTPUTS
%   String_Type sltableType: the currently-selected table type ("tabular" or "deluxetable")
%
% SEE ALSO
%   table_set_type
%%%%%%%%%%%%%%%%%%%%%%%%
private define sltableGetType() {
  return sltableType;
}

%%%%%%%%%%%%%%%%%%%%%%%%
% sltableNoteMark
%
% SYNOPSIS
%   Produces a table note mark
%
% USAGE
%   String_Type markText = sltableNoteMark(String_Type mark)
%
% DESCRIPTION
%   Produces table note mark (e.g., a superscripted character or symbol) code
%   depending on the value of sltableType. If sltableType == "deluxetable", uses
%   deluxetable's \tablenotemark command. If sltableType == "tabular", uses math
%   mode and \text to produce a superscripted mark.
%
% INPUTS
%   String_Type mark: mark to be used
%
% OUTPUTS
%   String_Type markText: formatted table note mark
%
% SEE ALSO
%   sltableNoteText
%%%%%%%%%%%%%%%%%%%%%%%%
private define sltableNoteMark(mark) {
  if(sltableType == "deluxetable") 
    return sprintf("\\tablenotemark{%s}",mark);
  else
    return sprintf("$^{\\text{%s}}$",mark);
}

%%%%%%%%%%%%%%%%%%%%%%%%
% sltableNoteText
%
% SYNOPSIS
%   Produces a table footnote
%
% USAGE
%   String_Type footnoteText = sltableNoteText(String_Type mark, String_Type
%   text)
%
% DESCRIPTION
%   Produces code for a table footnote depending on the value of sltableType. If
%   sltableType == "deluxetable", uses deluxetable's \tablenotetext command. If
%   sltableType == "tabular", uses \flushleft and \footnotesize to produce a
%   footnote.
%
% INPUTS
%   String_Type mark: mark to be used
%   String_Type text: footnote text
%
% OUTPUTS
%   String_Type foonoteText: formatted table note text
%
% SEE ALSO
%   sltableNoteMark
%%%%%%%%%%%%%%%%%%%%%%%%
private define sltableNoteText(mark,text) {
  if(sltableType == "deluxetable") 
    return sprintf("\\tablenotetext{%s}{%s}",mark,text);
  else
    return sprintf("\\flushleft\\footnotesize{$^{\\text{%s}}$%s}",mark,text);
}

% Table header things - captions, column headers
%%%%%%%%%%%%%%%%%%%%%%%%
% sltableCaption
%
% SYNOPSIS
%   Creates an appropriate table caption statement with label
%
% USAGE
%   String_Type caption = table_caption(String_Type text, String_Type label);
%
% DESCRIPTION
%   Creates a table caption of the form \caption{<text> \label{<label>}} (for
%   tabular) or \tablecaption{<text> \label{<label>}} (for deluxetable).
%
% INPUTS
%   String_Type text: The table's caption.
%   String_Type label: The LaTeX label for the table
%
% OUTPUTS
%   String_Type caption: The formatted LaTeX table caption
%
% SEE ALSO
%
%%%%%%%%%%%%%%%%%%%%%%%%
private define sltableCaption(text,label) {
  variable continueFlag = qualifier("continue",0);
  if(sltableType == "deluxetable")
    return sprintf("\\tablecaption{%s\\label{%s}}",text,label);
  else
    if(continueFlag) {
      return sprintf("\\contcaption{%s\\label{%s}}",text,label+"_continued");
    } else {
      return sprintf("\\caption{%s\\label{%s}}",text,label);
    }
}

%%%%%%%%%%%%%%%%%%%%%%%%
% sltableColHead
%
% SYNOPSIS
%   Create a formatted table column header.
%
% USAGE
%   String_Type colhead = sltableColHead(String_Type text)
%
% DESCRIPTION
%   Create a properly-formatted column header containing the supplied text for
%   the currently-selected table type. Note that if sltableType == "tabular",
%   this just returns the supplied string, as tabular does not treat the column
%   headers any differently from the other parts of the table body. For
%   deluxetables, it uses the \colhead command.
%
% INPUTS
%   String_Type text: Text for the column header.
%
% OUTPUTS
%   String_Type colhead: The formatted column header.
%
% SEE ALSO
%   sltableColHeads
%%%%%%%%%%%%%%%%%%%%%%%%
private define sltableColHead(text) {
  if(sltableType == "deluxetable")
    return sprintf("\\colhead{%s}",text);
  else
    return sprintf("%s",text);
}

%%%%%%%%%%%%%%%%%%%%%%%%
% sltableColHeads
%
% SYNOPSIS
%   Create a formatted table header statement
%
% USAGE
%   String_Type sltableColHeads = sltableColHeads(String_Type colHeads)
%
% DESCRIPTION
%   Given the full text of the column headers (as a single string!), returns
%   the table header. Note that tabular doesn't treat the column headers and
%   table header any differently than any other table lines, so if sltableType ==
%   "tabular", this function just returns the supplied string. For
%   deluxetables, it uses the \tablehead command.
%
% INPUTS
%   String_Type colHeads: a single string (not an array!) containing all the
%   column headers separated by &'s.
%
% OUTPUTS
%   String_Type sltableColHeads: Formatted table header line
%
% SEE ALSO
%   sltableColHead
%%%%%%%%%%%%%%%%%%%%%%%%
private define sltableColHeads(text) {
  if(sltableType == "deluxetable")
    return sprintf("\\tablehead{%s}",text);
  else
    return sprintf("%s",text);
}

%%%%%%%%%%%%%%%%%%%%%%%%
% sltableColJust
%
% SYNOPSIS
%   Build column-justification string for n columns
%
% USAGE
%   String_Type justString = table_column_just(Integer_Type n)
%
% DESCRIPTION
%   Build a column-justification string with the first column left-justified
%   and the remaining columns right-justified
%
% INPUTS
%   Integer_Type n: number of columns
%
% OUTPUTS
%   String_Type justString: column justification string
%
% SEE ALSO
%
%%%%%%%%%%%%%%%%%%%%%%%%
private define sltableColJust(n) {
  variable i;
  variable justString = "";
  if(n < 1) {
    message("Error: trying to make a table with no columns.");
    throw UsageError;
  }
  _for i (0,n-1,1) {
    if(i == 0) {
      justString += "l";
    } else {
      justString += "r";
    }
  }
  return justString;
}

%%%%%%%%%%%%%%%%%%%%%%%%
% sltableRoundToDigit
%
% SYNOPSIS
%   Round a value to a number of digits.
%
% USAGE
%   String_Type val = sltableRoundToDigit(Double_Type value, Integer_Type
%   numDigits);
%
% DESCRIPTION
%   Produces a LaTeX string for "value" rounded to "numDigits" decimal digits.
%
% INPUTS
%   Double_Type value: the value to be rounded.
%   Integer_Type numDigits: the desired number of decimal places.
%
% OUTPUTS
%   String_Type val: a string containing the rounded value.
%
% SEE ALSO
%   sltableRound
%%%%%%%%%%%%%%%%%%%%%%%%
private define sltableRoundToDigit(val,sf) {
  variable totDig,decDig;
  variable fmt;
  variable neg = (val < 0 ? "-" : "");
  variable zeroString = "";
  % Only do the following if val is non-zero
  if(val == 0) { % If val is zero, simpler to format
    fmt = sprintf("%%%i.%if",sf+1,sf);
    return(sprintf(fmt,val));
  } else {
    val = abs(val);
    variable dig = int(floor(log10(val))); % power of 10 of leading digit
    % if number is less than 1: leading zero, but no other integer digits
    if(dig < 0) { 
      dig *= -1;
      dig += sf-1;
      fmt = "%.${dig}f"$;
    } else if (dig < sf-1) { % leading digit is at least 10^0 but less than 10^sf
      totDig = sf + 1;
      decDig = sf - dig - 1;
      fmt = "%${totDig}.${decDig}f"$;
    } else { % Bigger than 10^sf - format as integer now
      % need to divide by power of ten and then add zeros to end of string
      variable pow10 = dig - sf + 1;
      val *= 10^-pow10;
      val = nint(val);
      fmt = "%${sf}i"$;
      zeroString = (pow10 ? sprintf("%0${pow10}i"$,0) : "");
    }
    return(neg + sprintf(fmt,val) + zeroString);
  }
}


%%%%%%%%%%%%%%%%%%%%%%%%
% sltableRound
%
% SYNOPSIS
%   Round a value to its uncertainty or to a number of digits and return a
%   LaTeX string.
%
% USAGE
%   String_Type val = sltableRound(value[,minimum,maximum]; qualifiers)
%
% DESCRIPTION
%   Produces a LaTeX string for a value, possibly with errors. Uses
%   TeX_value_pm_error() for the "standard" case (a value with an asymmetric
%   confidence interval) and sltableRoundToDigit() otherwise. If the value has no
%   errors, it is printed to three significant figures. If it is frozen, it is
%   surrounded by parentheses (or whatever you provide as the "frozendelim"
%   qualifier) and printed to three sig figs.
%   Upper/lower limits are determined automatically by a parameter's min/max
%   values crossing zero and the "limit" field of the provided struct being set
%   to 1. If "limit" is zero, the upper and lower limits having different sign
%   is not interpreted as having any significance (so for something like a
%   photon index, which can be zero without meaning anything special, you'd
%   want to set limit = 0).
%
% INPUTS
%
% OUTPUTS
%
% SEE ALSO
%   sltableRoundToDigit
%%%%%%%%%%%%%%%%%%%%%%%%
private define sltableRound() {
  variable value, mini, maxi, limit = 0, nodata = 0, frz = 0;
  if(_NARGS == 1) {
    (value) = ();
  } else if(_NARGS == 3) {
    (value,mini,maxi) = ();
  } else {
    usage("String_Type val = sltableRound(value[,minimum, maximum]; qualifiers)");
  }

  variable frozenDelim = qualifier("frozendelim",["(",")"]);
  variable nodataSymb = qualifier("nodata",sltableType=="deluxetable"?"\\nodata":"\\ldots");

  if(typeof(value) == Struct_Type && typeof(value.value) == String_Type) {
    nodata = struct_field_exists(value,"nodata") ? value.nodata : 0;
    value = value.value;
  } else if(typeof(value) == Struct_Type && typeof(value.value) != String_Type) {
    mini = struct_field_exists(value,"min") ? value.min : value.value;
    maxi = struct_field_exists(value,"max") ? value.max : value.value;
    frz = struct_field_exists(value,"freeze") ? value.freeze : 0;
    limit = struct_field_exists(value,"limit") ? value.limit : 1;
    nodata = struct_field_exists(value,"nodata") ? value.nodata : 0;
    value = value.value;
  } else if(typeof(mini) != Undefined_Type) {
    frz = 0;
    limit = 0;
    nodata = 0;
  } else {
    mini = value;
    maxi = value;
    frz = 0;
    limit = 0;
    nodata = 0;
  }

  if(nodata) { % first, if "nodata" was set, output the nodataSymb
    return nodataSymb;
  } else if (typeof(value) == String_Type) { % output strings as-is
      return value;
  } else if (mini == maxi and frz == 0) {  % parameter has no errors
    return sprintf("$%s$",sltableRoundToDigit(value,3));
  } else if(frz) {            % parameter is frozen - output (value)
    return sprintf("$%s%s%s$",frozenDelim[0],sltableRoundToDigit(value,3),frozenDelim[1]);
  } else if (limit and maxi > 0 and mini <= 0) {    % upper limit
    return sprintf("$< %s$",sltableRoundToDigit(maxi,3));
  } else if (limit and mini < 0 and maxi >= 0) {    % lower limit
    return sprintf("$> %s$",sltableRoundToDigit(mini,3));
  } else {
    return TeX_value_pm_error(value,mini,maxi;sci=3,noparens);
  }
}

%%%%%%%%%%%%%%%%%%%%%%%%
define sltableBuildBody()
%%%%%%%%%%%%%%%%%%%%%%%%
%!%+
%\function{sltableBuildBody}
%\synopsis{Build a 2D array of table cells}
%\usage{String_Type table[] = sltableBuildBody(Array_Type par1[, Array_Type par2,...])}
%\description
%   Builds the "body" of a table (in the form of a 2D array of strings,
%   containing the fields of the table).
%
%   Arguments should be either 1D arrays or structs, the same as one would give
%   to sltable(). An array of strings will be used as-is. Arrays of numbers
%   will be rounded to 3 significant figures.  Structs allow the handling of
%   error bars and offer considerably more flexibility, as defined below:
%
%   Struct arguments should, at minimum, have a "value" field, which must be
%   an array containing the value of the parameter for each row (or column, if
%   the table is horizontally-aligned). Further fields can be used to modify
%   the output. All should be arrays of the same length as the value field,
%   and they have the following names and uses:
%
%   min: minimum value of the parameter.
%   max: maximum value of the parameter. Min & max determine rounding & errors.
%   freeze: if 1, parameter is frozen, if 0, parameter is thawed.
%   limit: if 0, parameter can be zero without being an upper/lower limit.
%
%   Note that most of these are the same as those in the struct returned by
%   get_par_info(). The exception is the "limit" field, which determines how a
%   value of 0 for the parameter is handled. If "limit" is 1, then a confidence
%   interval containing zero is interpreted as an upper or lower limit. If
%   "limit" is 0, the value and error bars are typeset as a standard confidence
%   interval. E.g., one would set limit to 1 for a power-law normalization and
%   to 0 for a power-law index (the system is not flexible enough at the moment
%   to handle pathological cases like upper/lower limits on logarithmic
%   parameters like photon indices).
%
%   The number of "rows" in the table is determined by the length of the first
%   array or the first struct's value field. All later arrays and struct fields
%   should have the same number of elements.
%
%\qualifiers{
%\qualifier{horiz}{: Integer_Type. If zero, each argument defines one column of
%           the table. If nonzero, each argument defines one row. Default 0.}
%\qualifier{frozendelim}{: String_Type[2]. Defines strings to use before and
%           after a frozen parameter value. Default ["(",")"].}
%\qualifier{nodata}{: String_Type. Defines string to use when no data is
%           present in a cell. Default is "\\nodata" for deluxetables and
%           "\\ldots" for tabular tables.}
%\qualifier{rownames}{: String_Type[] or List_Type. Names for rows of table.
%         If given as a List_Type of String_Type arrays, each element of the
%         list will be included in its own column (this is useful for, e.g.,
%         putting the parameter name and the units in separate columns).}
%}
%
%\seealso{sltable}
%!%-
{
  if(_NARGS < 1) {
    usage("String_Type table[] = sltableBuildBody(Struct_Type par1[, Struct_Type par2,...])");
    throw StackUnderflowError;
  }
  % pop all arguments into parList
  variable parList = __pop_list(_NARGS);
  variable horiz = qualifier("horiz",0);
  variable frozenDelim = qualifier("frozendelim",["(",")"]);
  variable nodataSymb = qualifier("nodata",sltableType=="deluxetable"?"\\nodata":"\\ldots");
  variable rowNames = qualifier("rownames",String_Type[0]);
  if(length(rowNames) && typeof(rowNames) != List_Type) rowNames = {rowNames};
  variable i,j;
  variable value;
  variable numRows, numCols;
  variable theTable;

  if(typeof(parList[0]) != Struct_Type) {
    numRows = length(parList[0]);
  } else {
    numRows = length(parList[0].value);
  }
  numCols = length(parList);
  if(horiz) {
    numRows += length(rowNames);
  } else {
    numCols += length(rowNames);
  }

  theTable = String_Type[numRows,numCols];

  _for i (0,length(rowNames)-1,1) {
    _for j (0,length(rowNames[i])-1,1) {
      if(horiz) {
        theTable[i,j] = rowNames[i][j];
      } else {
        theTable[j,i] = rowNames[i][j];
      }
    }
  }

  _for i (0,length(parList)-1,1) {
    variable iNdx,jNdx,isRowName;
    _for j (0,numRows-1,1) {
      if(horiz) {
        if(j < length(rowNames)) {
          isRowName = 1;
        } else {
          isRowName = 0;
          iNdx = i;
          jNdx = j - length(rowNames);
        }
      } else {
        iNdx = i + length(rowNames);
        jNdx = j;
        isRowName = 0;
      }
      if(not(isRowName)) {
        if(typeof(parList[i]) == Struct_Type) {
          value = struct_filter(parList[i],jNdx;copy);
        } else {
          value = parList[i][jNdx];
        }
        theTable[j,iNdx] = sltableRound(value;frozendelim=frozenDelim,nodata=nodataSymb);
      }
    }
  }
  return theTable;
}

%%%%%%%%%%%%%%%%%%%%%%%%
% sltableBuildColHead
%
% SYNOPSIS
%   Build the column headers to a LaTeX table.
%
% USAGE
%   String_Type header = sltableBuildColHead();
%
% DESCRIPTION
%   Returns a string containing a LaTeX table column header. Use sltableSetType
%   to change whether this creates a deluxetable column header (using \tabhead
%   and \colhead) or a standard tabular table.
%
% INPUTS
%
% OUTPUTS
%   String_Type header: the LaTeX column headers.
%
% SEE ALSO
%   sltableSetType, sltableBuildBody, sltableBuildFooter
%%%%%%%%%%%%%%%%%%%%%%%%
private define sltableBuildColHead() {
  variable colNames = qualifier("colnames",String_Type[0]);
  variable numCols = qualifier("numCols",0);
  if(length(colNames) && typeof(colNames) != List_Type) colNames = {colNames};
  variable i,j;
  variable line = "";

  _for i (0,length(colNames)-1,1) {
    _for j (0,numCols-1,1) {
      if(j < numCols - length(colNames[i])) {
        line += "& ";
      } else {
        line += sltableColHead(colNames[i][j - (numCols - length(colNames[i]))]);
        if(j - (numCols - length(colNames[i])) < length(colNames[i])-1) 
          line += "&";
      }
    }
    if(i < length(colNames)-1 or sltableType == "tabular") 
      line += ` \\ `;
  }
  line = sltableColHeads(line);
  return line;
}

%%%%%%%%%%%%%%%%%%%%%%%%
% sltableBuildHeader
%
% SYNOPSIS
%   Build the header to a LaTeX table.
%
% USAGE
%   String_Type header = sltableBuildHeader();
%
% DESCRIPTION
%   Returns a string containing a LaTeX table header. Use sltableSetType to
%   change whether this creates a deluxetable or a standard tabular table.
%
% INPUTS
%
% OUTPUTS
%   String_Type header: the LaTeX table header.
%
% SEE ALSO
%   sltableSetType, sltableBuildBody, sltableBuildFooter
%%%%%%%%%%%%%%%%%%%%%%%%
private define sltableBuildHeader() {
  variable header = "";
  variable longtable = qualifier("longtable",0);
  variable landscape = qualifier("landscape",0);
  variable numRows = qualifier("numRows");
  variable numCols = qualifier("numCols");
  variable tabletypesize = qualifier("tabletypesize","footnotesize");
  variable caption = qualifier("caption","");
  variable label = qualifier("label","placeholder");
  variable star = qualifier("star",0);
  variable horiz = qualifier("horiz",0);
  variable quals = __qualifiers;
  if(star) {
    star = "*";
  } else {
    star = "";
  }
  if(sltableType == "tabular") {
    if(landscape) {
      header += sltableTabs + `\begin{landscape}` + sltableEOL;
      sltableNTabs++;
    }
    header += sltableTabs + `\begin{table` + star + `}` + sltableEOL;
    sltableNTabs++;
  } else if(sltableType == "deluxetable") {
    if(longtable) header += sltableTabs + `\startlongtable` + sltableEOL;
    header += sltableTabs + `\begin{deluxetable` + star + `}{` + sltableColJust(numCols) + `}` + sltableEOL;
    sltableNTabs++;
    if(landscape) header += sltableTabs + `  \rotate` + sltableEOL;
    header += sltableTabs + `\tabletypesize{\` + tabletypesize + `}` + sltableEOL;
    header += sltableTabs + `\tablewidth{0pt}` + sltableEOL;
  }

  % Table caption + label
  header += sltableTabs + sltableCaption(caption,label) + sltableEOL;

  if(sltableType == "tabular") {
    header += sltableTabs + `\begin{tabular}{` + sltableColJust(numCols) + `}` + sltableEOL;
    header += sltableTabs + `\toprule` + sltableEOL;
  }

  % Add line of column heads
  header += sltableTabs + sltableBuildColHead(;;quals) + sltableEOL;

  % Startdata (or tabular equivalent)
  if(sltableType == "tabular") {
    header += sltableTabs + `\midrule` + sltableEOL;
  } else if(sltableType == "deluxetable") {
    header += sltableTabs + `\startdata` + sltableEOL;
  }

  sltableNTabs++;
  return header;
}

%%%%%%%%%%%%%%%%%%%%%%%%
% sltableBuildFooter
%
% SYNOPSIS
%   Build the footer to a LaTeX table.
%
% USAGE
%   String_Type footer = sltableBuildFooter();
%
% DESCRIPTION
%   Returns a string containing a LaTeX table footer. Use sltableSetType to
%   change whether this creates a deluxetable or a standard tabular table.
%
% INPUTS
%
% OUTPUTS
%   String_Type footer: the LaTeX table footer.
%
% SEE ALSO
%   sltableSetType, sltableBuildBody, sltableBuildHeader
%%%%%%%%%%%%%%%%%%%%%%%%
private define sltableBuildFooter() {
  variable noteText = qualifier("noteText",String_Type[0]);
  variable noteSym = qualifier("noteSym",String_Type[0]);
  variable longtable = qualifier("longtable",0);
  variable landscape = qualifier("landscape",0);
  variable star = qualifier("star",0);
  if(star) {
    star = "*";
  } else {
    star = "";
  }
  variable footer = "";
  if(sltableType == "tabular") {
    footer += sltableTabs + `\bottomrule` + sltableEOL;
    sltableNTabs--;
    footer += sltableTabs + `\end{tabular}` + sltableEOL;
  } else if(sltableType == "deluxetable") {
    sltableNTabs--;
    footer += sltableTabs + `\enddata` + sltableEOL;
  }
  variable i;
  _for i (0,length(noteText)-1,1)
    footer += sltableTabs + sltableNoteText(noteSym[i],noteText[i]) + sltableEOL;
  sltableNTabs--;
  if(sltableType == "tabular") {
    footer += sltableTabs + `\end{table` + star + `}` + sltableEOL;
  } else if (sltableType == "deluxetable") {
    footer += sltableTabs + `\end{deluxetable` + star + `}` + sltableEOL;
  }
  return footer;
}


%%%%%%%%%%%%%%%%%%%%%%%%
define sltable()
%%%%%%%%%%%%%%%%%%%%%
%!%+
%\function{sltable}
%\synopsis{Generate a LaTeX table}
%\usage{String_Type table = sltable(par1[,par2,par3,...])}
%\description
%   sltable() is intended to streamline the production of tables of,
%   e.g., spectral parameters with error bars, although it should be flexible
%   enough to produce most simply-structured tables. There is a set of examples
%   on the Remeis wiki:
%   http://www.sternwarte.uni-erlangen.de/wiki/doku.php?id=isis:sltable
%
%   By default this builds tables using the "deluxetable" package; this can be
%   disabled to produce standard "tabular" tables by setting the "deluxe"
%   qualifier to zero. The deluxetable environment has been tested using the
%   latest aastex61.cls stylefile. Tabular tables will require the "booktabs"
%   package, as they provide the \\toprule, \\midrule, and \\bottomrule
%   commands used here.
%
%   Each argument given to sltable() provides the values of one
%   column of the table (or one row, if the "horiz" qualifier is nonzero).
%   The length of each argument (or the length of the "value" field of a
%   Struct_Type argument) defines the number of rows (or columns, if horiz=1).
%   The arguments can be String_Type (in which case they are printed
%   literally), Double_Type (or some other numerical type), in which case they
%   are printed to three decimal places (TODO: figure out a better, more
%   flexible way of doing this), or Struct_Type, as defined below.
%
%   Struct_Type arguments should at least have a "value" field, which should be
%   an array of some type. If only the "value" field is present, the value
%   printed to the table follows the rules for String_Type and Double_Type
%   arguments above. Further fields which can be provided are:
%     min: the minimum values of this parameter
%     max: the maximum values of this parameter
%     freeze: if 1, the parameter is frozen, if 0, it is thawed
%     limit: if 1, this can be an upper/lower limit
%     nodata: if 1, there is no data here and "..." should be printed
%   These should all be arrays of the same length as the "value" field, and
%   allow for the printing of error bars and indicating upper/lower limits and
%   frozen parameters.
%
%   If the min and max fields are provided and the parameter is not frozen and
%   not an upper or lower limit, the confidence intervals are printed using the
%   TeX_value_pm_error() function. If it is an upper or lower limit, it is
%   rounded to three decimal places and indicated accordingly with "<" or ">"
%   symbols. If frozen, it is rounded to three decimal places and surrounded by
%   parentheses (these delimiters can be customized by changing the
%   "frozendelim" qualifier).
%
%   If the "nodata" field is nonzero, then a "no data" indicator will be
%   printed. By default, for a deluxetable, this is "\\nodata" and for a
%   tabular table it is "\\ldots". This is useful if you are putting multiple
%   models which do not share the same parameters into the same table.
%
%   This is a lot of words, so here is an
%   EXAMPLE
%   This will produce a simple 3x3 table with values with error bars, some
%   frozen parameters, some upper limits, and some cells in the table filled
%   with literal strings.
%   \code{
%   variable par1 = struct{value=[1,2,3],min=[0.9,1.9,0.0],max=[1.1,2.3,3.2],
%     freeze=[0,1,0],limit=[1,1,1]};
%   variable par2 = struct{value=[1,2,3],min=[0.9,1.9,2.9],max=[1.1,2.3,3.2],
%     freeze=[1,0,0],limit=[1,1,1]};
%   variable par3 = struct{value=["foo","bar","baz"]};
%   variable parnames = ["par1","par2","par3"];
%   variable parunits = ["unit1","unit2","unit3"];
%   variable obsNames = ["obs1","obs2","obs3"];
%   variable notes = ["note1","note2"];
%   variable noteSym = ["1","2"];
%   variable t = sltable(par1,par2,par3;
%     colnames={parnames,parunits},rownames=obsNames,
%     notes={notes,noteSym},label="tab:example",
%     caption="this is the table's caption");
%   }
%   The variable "t" now contains the full LaTeX table - drop it into a LaTeX
%   document and see what it ends up looking like. Note the use of the
%   "colnames" and "rownames" qualifiers to define the names and units for the
%   columns and rows, and how List_Type and Array_Type values are interpreted
%   differently there. Footnotes are also possible via the "notes" qualifier
%   (although currently we can't place the footnote markers into the table
%   automatically - you'll have to handle that yourself).
%
%   This script is under development. Contact Paul Hemphill (pbh@space.mit.edu)
%   if you find any bugs.
%
%\qualifiers{
%\qualifier{deluxe}{: Integer_Type. If nonzero, we'll produce a deluxetable.
%        Otherwise, tabular. Tabular tables aren't as fancy and aren't
%        implemented as well at the moment. In theory we could add other table
%        types. Default 1.}
%\qualifier{horiz}{: Integer_Type. If nonzero, arguments to sltable
%        indicate _rows_ of the table. If 0, they indicate _columns_.}
%\qualifier{rownames}{: String_Type[] or List_Type[]. Names for the rows
%        of the table. Multiple columns for the row names (e.g., parameter names
%        and units in separate columns) can be handled by providing a List_Type
%        containing multiple String_Type arrays.}
%\qualifier{colnames}{: String_Type[] or List_Type[]. Names for the columns of
%        the table (i.e., the column headers). Similar to rownames above,
%        multi-line headers can be produced by passing a List_Type to this
%        qualifier.} 
%\qualifier{caption}{: String_Type. LaTeX caption for the table. Default is
%        blank. Don't include a label statement here - that's handled by the 
%        "label" qualifier below.}
%\qualifier{label}{: String_Type. LaTeX label for the table. Default is
%        "placeholder," so make sure to set this.}
%\qualifier{nodata}{: String_Type, set to what should be printed if there is no
%         data for a particular field (e.g., if you are putting multiple models
%         into the same table and they do not share the same parameters).}
%\qualifier{frozendelim}{: String_Type[], two-element string array containing
%        opening and closing delimiters for a frozen value. By default this is
%        ["(",")"], i.e., the frozen value is surrounded by parentheses.}
%\qualifier{star}{: Integer_Type. If nonzero, the table will be a table* or
%        deluxetable*. If 0, the table will be a table or deluxetable.}
%\qualifier{tabletypesize}{: String_Type. Sets the font size of the table.
%        Should be a LaTeX font size without the backslash. Default is
%        "footnotesize".}
%\qualifier{longtable}{: Integer_Type. If nonzero (and we're making a
%        deluxetable), this is a long table, so a startlongtable statement will
%        be included in the table header. I don't think tabular tables do
%        anything with this right now. Default 0.}
%\qualifier{landscape}{: Integer_Type. If nonzero, this is a
%        landscape-orientation table. Includes a \\rotate command if
%        deluxetable, or wraps everything in a begin/end landscape block if
%        tabular. Default 0.}
%\qualifier{notes}{: List_Type[2]. Element 0 should be a String_Type[] array of
%        the text of any footnotes; element 1 should be a String_Type[] array of
%        the symbols associated with those notes.}
%}
%
%\seealso{TeX_value_pm_error}
%!%-
{
  sltableNTabs = 0; % reset tabs to zero when sltable is called
  variable theHeader,theTable,theFooter;
  variable args = __pop_list(_NARGS);
  variable quals = __qualifiers;
  variable horiz = qualifier("horiz",0);
  if(_isnull(quals)) quals = empty_struct;

  if(qualifier("deluxe",1)) {
    sltableSetType("deluxetable");
  } else {
    sltableSetType("tabular");
  }

  theTable = sltableBuildBody(__push_list(args);;quals);
  if(horiz) theTable = transpose(theTable);

  variable numRows = length(theTable[*,0]),
           numCols = length(theTable[0,*]);
  quals = create_struct_field(quals,"numRows",numRows);
  quals = create_struct_field(quals,"numCols",numCols);

  theHeader = sltableBuildHeader(;;quals);
  variable i,j;
  variable line = theHeader;
  _for i (0,numRows-1,1) {
    _for j (0,numCols-1,1) {
      if(j == 0)
        line += sltableTabs;
      line += theTable[i,j];
      if(j < numCols-1) {
        line += " & ";
      } else {
        if(i < numRows-1 or sltableType == "tabular" or sltableType == "deluxetable")
          line += ` \\ `;
        line += sltableEOL;
      }
    }
  }
  if(qualifier_exists("notes")) {
    variable noteText,noteSym,notes;
    notes = qualifier("notes");
    noteText = notes[0];
    noteSym = notes[1];
    quals = create_struct_field(quals,"noteText",noteText);
    quals = create_struct_field(quals,"noteSym",noteSym);
  }
  theFooter = sltableBuildFooter(;;quals);
  line += theFooter;
  return line;
}
