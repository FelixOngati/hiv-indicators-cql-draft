library TXPVLS version '1.0.1'

using FHIR version '4.0.1'
include FHIRHelpers version '4.0.1' called FHIRHelpers
// SNOMED-CT, International Edition
codesystem "SNOMED-CT": 'http://snomed.info/sct' version 'http://snomed.info/sct/900000000000207008'

codesystem "ISO-8601-Derived Periods": 'http://ohie.org/ValueSet/iso-8601-derived-periods'

// History of ART Therapy
code "History of antiretroviral therapy (situation)": '432101000124108' from "SNOMED-CT" display 'History of antiretroviral therapy (situation)'

codesystem "CIEL": 'https://openconceptlab.org/orgs/CIEL/sources/CIEL'
 
code "Viral Load Quantitative": '856' from "CIEL" display 'HIV viral load'
 
code "Viral Load Qualitative": '1305' from "CIEL" display 'HIV VIRAL LOAD, QUALITATIVE'

// Age Groups
code "P0Y--P1Y": 'P0Y--P1Y' from "ISO-8601-Derived Periods" display '< 1 year'
code "P1Y--P5Y": 'P1Y--P5Y' from "ISO-8601-Derived Periods" display '1-4 years'
code "P5Y--P10Y": 'P5Y--P10Y' from "ISO-8601-Derived Periods" display '5-9 year'
code "P10Y--P15Y": 'P10Y--P15Y' from "ISO-8601-Derived Periods" display '10-14 year'
code "P15Y--P20Y": 'P15Y--P20Y' from "ISO-8601-Derived Periods" display '15-19 year'
code "P20Y--P25Y": 'P20Y--P25Y' from "ISO-8601-Derived Periods" display '20-24 year'
code "P25Y--P30Y": 'P25Y--P30Y' from "ISO-8601-Derived Periods" display '25-29 year'
code "P30Y--P35Y": 'P30Y--P35Y' from "ISO-8601-Derived Periods" display '30-34 year'
code "P35Y--P40Y": 'P35Y--P40Y' from "ISO-8601-Derived Periods" display '35-39 year'
code "P40Y--P50Y": 'P40Y--P50Y' from "ISO-8601-Derived Periods" display '40-49 year'
code "P50Y--P9999Y": 'P50Y--P9999Y' from "ISO-8601-Derived Periods" display '50+ years'


parameter "Measurement Period" Interval<DateTime>

/*
Percentage of ART patients with a suppressed viral load (VL) result (<1000 copies/ml)
documented in the medical or laboratory records/laboratory information systems (LIS) within the past 12 months
 */

context Patient

define "ART Observation":
  Last(( [Observation: "Viral Load Quantitative"]
        union [Observation: "Viral Load Qualitative"] ) O
        where O.status in {'final', 'amended', 'corrected'}
        and O.effective in day of "Measurement Period"
          sort by effective)

define "ART Last Three Months":
    "ART Observation" A where A.effective starts 3 months or more before end of "Measurement Period"

  define "Initial Population":
    "ART Observation"


  define "Numerator":
    "Viral Load Suppresed"
          
define "Viral Load Suppresed":
       "ART Last Three Months" V where (V.value as Quantity)  <= 1000


  define "Denominator":
    "Initial Population"
         
         
// Age Group
define "Age Group":
  case
    when AgeInYearsAt(start of "Measurement Period") in Interval[0, 1) then "P0Y--P1Y"
    when AgeInYearsAt(start of "Measurement Period") in Interval[1, 5) then "P1Y--P5Y"
    when AgeInYearsAt(start of "Measurement Period") in Interval[5, 10) then "P5Y--P10Y"
    when AgeInYearsAt(start of "Measurement Period") in Interval[10, 15) then "P10Y--P15Y"
    when AgeInYearsAt(start of "Measurement Period") in Interval[15, 20) then "P15Y--P20Y"
    when AgeInYearsAt(start of "Measurement Period") in Interval[20, 25) then "P20Y--P25Y"
    when AgeInYearsAt(start of "Measurement Period") in Interval[25, 30) then "P25Y--P30Y"
    when AgeInYearsAt(start of "Measurement Period") in Interval[30, 35) then "P30Y--P35Y"
    when AgeInYearsAt(start of "Measurement Period") in Interval[35, 40) then "P35Y--P40Y"
    when AgeInYearsAt(start of "Measurement Period") in Interval[40, 50) then "P40Y--P50Y"
    when AgeInYearsAt(start of "Measurement Period") in Interval[50, null] then "P50Y--P9999Y"
    else null
  end
 
// Sex
define "Sex": Patient.gender
 
// Age Group/Sex
define "Age Group/Sex": "Age Group".code + ':' + "Sex"