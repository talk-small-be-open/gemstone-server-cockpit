"
Please describe the package using the class comment of the included manifest class. The manifest class also includes other additional metadata for the package. These meta data are used by other tools such as the SmalllintManifestChecker and the critics Browser
"
Class {
	#name : 'ManifestGemstoneServerCockpit',
	#superclass : 'PackageManifest',
	#category : 'GemstoneServerCockpit-Manifest',
	#package : 'GemstoneServerCockpit',
	#tag : 'Manifest'
}

{ #category : 'code-critics' }
ManifestGemstoneServerCockpit class >> ruleParseTreeLintRuleV1FalsePositive [
	^ #(#(#(#RGMethodDefinition #(#GSCWebApplicationSchemeV1 #buildEmptyConfiguration #false)) #'2023-03-30T10:59:12.403239+02:00') #(#(#RGMethodDefinition #(#GSCWebApplicationSchemeV1 #buildDefaultConfiguration #false)) #'2023-04-27T10:31:01.518802+02:00') )
]

{ #category : 'code-critics' }
ManifestGemstoneServerCockpit class >> ruleSentNotImplementedRuleV1FalsePositive [
	^ #(#(#(#RGMethodDefinition #(#GSCWebApplicationSchemeV1 #buildEmptyConfiguration #false)) #'2023-03-30T10:58:52.931807+02:00') #(#(#RGMethodDefinition #(#GSCWebApplicationSchemeV1 #buildDefaultConfiguration #false)) #'2023-04-27T08:05:36.281298+02:00') #(#(#RGMethodDefinition #(#GSCRootScheme #buildDefaultConfiguration #false)) #'2023-05-11T14:10:22.541978+02:00') )
]
