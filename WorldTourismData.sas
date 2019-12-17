data cleaned_tourism;
	length country_Name $300 Tourism_Type $20 ;
	retain Country_Name ""  Tourism_Type "" ;
	set Tourism(drop=_1995-_2013) ;
	if A ne . then Country_Name=Country ;
	if lowcase(Country)="inbound tourism" then Tourism_Type="Inbound tourism";
	else if lowcase(Country)='outbound tourism' then Tourism_Type="Outbound tourism";
	if Country_Name ne Country and Country ne Tourism_Type;
	Series=upcase(series);
	if Series=".." then Series="";
	ConversionType=strip(scan(country,-1," "));
	if _2014='..' then _2014='.';
	if ConversionType = 'Mn' then do;
		if _2014 ne "." then Y2014 = input(_2014,16.) * 1000000;
			else Y2014=.;
		Category=cat(scan(country,1,'-','r'),' - US$');
	end;
	else if ConverdionType="Thousands" then do;
		if _2014 ne "." then Y2014 = input(_2014,16.) * 1000;
			else Y2014=.;
	if ConversionType = 'Mn' then
 Category=cat(scan(country,1,'-','r')," - US$");
else if ConversionType = 'Thousands' then
Category=scan(country,1,'-','r');
		Category=scan(country,1,'-','r');
	end;
	format Y2014 comma25.;
	drop A ConversionType Country _2014;
run;

proc format;
 value continents
 1 = "North America"
 2 = "South America"
 3 = "Europe"
 4 = "Africa"
 5 = "Asia"
 6 = "Oceania"
 7 = "Antarctica";
run;

proc sort data=country_info(rename=(Country=Country_Name))
 out=Country_Sorted;
 by Country_Name;
run;

data Final_Tourism NoCountryFound(keep=Country_Name);
 merge cleaned_tourism(in=t)
 country_sorted(in=c);
 by country_name;
 if t=1 and c=1 then output Final_Tourism;
 if (t=1 and c=0) and first.country_name then
 output NoCountryFound;
 format Continent continents.;
run;

proc freq data=final_tourism nlevels;
	tables category series Tourism_Type Continent /nocum nopercent;
run;

proc means data=final_tourism min mean max maxdec=0;
	var Y2014;
run;

proc means data=final_tourism mean min max maxdec=0;	
	var y2014;
	class Continent;
	where Category="Arrivals";
run;

proc means data=final_tourism mean maxdec=0;	
	var y2014;
	where lowcase(Category) contains "tourism expenditure in other countries";
run;
