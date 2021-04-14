library TXPVLS version '1.0.1'

using FHIR version '4.0.1'
include FHIRHelpers version '4.0.1' called FHIRHelpers
include AgeRanges version '1.0.1' called AR

// SNOMED-CT, International Edition
codesystem "SNOMED-CT": 'http://snomed.info/sct' version 'http://snomed.info/sct/900000000000207008'

// LOINC, 2.63+
codesystem "LOINC": 'http://loinc.org'

// History of ART Therapy
code "Already on ART and New on ART": '713540004' from "SNOMED-CT" display 'Already on ART and New on ART'

code "HIV Positive": '165816005' from "SNOMED-CT" display 'HIV Positive'

code "HIV 1 and 2 tests - Meaningful Use set": '75622-1' from "LOINC" display 'HIV 1 and 2 tests - Meaningful Use set'

valueset "Human Immunodeficiency Virus (HIV) Laboratory Test Codes (Ab and Ag)": 'urn:oid:2.16.840.1.113762.1.4.1056.50'

codesystem "CIEL": 'https://openconceptlab.org/orgs/CIEL/sources/CIEL'

code "Viral Load Quantitative": '856' from "CIEL" display 'HIV viral load'

code "Viral Load Qualitative": '1305' from "CIEL" display 'HIV VIRAL LOAD, QUALITATIVE'


parameter "Measurement Period" Interval<DateTime>

/*
Percentage of ART patients with a suppressed viral load (VL) result (<1000 copies/ml)
documented in the medical or laboratory records/laboratory information systems (LIS) within the past 12 months
 */

context Patient
/* Patient has to be HIV+ */
define "HIV Test Observation":
  (
    [Observation: "Human Immunodeficiency Virus (HIV) Laboratory Test Codes (Ab and Ag)"]
      union [Observation: "HIV 1 and 2 tests - Meaningful Use set"]
  ) O
    where O.status in {'final', 'amended', 'corrected'}
      and O.value is not null

/* Positive check based on Condition */
/* define "HIV Positive Observation":
    [Condition: "HIV Positive"] */
/* Positive check based on Observation */
define "HIV Positive Observation":
    exists ("HIV Test Observation" O where O.value ~ "HIV Positive") or exists ([Condition: "HIV Positive"])


/* Check if patient is on ART within the reporting period for at least 3 months before end of measuring period*/

define "ART Observation":
  Last(( [Observation: "Viral Load Quantitative"]
        union [Observation: "Viral Load Qualitative"] ) O
        where O.status in {'final', 'amended', 'corrected'}
        and O.effective in day of "Measurement Period"
          sort by effective)

define "ART Last Three Months":
     [Observation: "Already on ART and New on ART"] A where A.effective starts 3 months or more before end of "Measurement Period"

define "HIV+ With At Least 3 Months ART":
  "HIV Positive Observation" and exists("ART Last Three Months")


define "Initial Population":
  "HIV+ With At Least 3 Months ART"


define "Numerator":
  "Viral Load Suppresed"

define "Viral Load Suppresed":
       "ART Last Three Months" V where (V.value as Quantity)  <= 1000


define "Denominator":
    "Initial Population"

// Sex
define "Sex": Patient.gender

// Age Group/Sex
define "AGE_GROUP:SEX": AR."Age Group".code + ':' + "Sex"
