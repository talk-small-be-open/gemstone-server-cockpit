Class {
	#name : #BaselineOfGemstoneServerCockpit,
	#superclass : #BaselineOf,
	#category : #BaselineOfGemstoneServerCockpit
}

{ #category : #baselines }
BaselineOfGemstoneServerCockpit >> baseline: spec [
	<baseline>
	spec
		for: #common
		do: [
			spec baseline: 'Seaside3' with: [
				spec
					repository: 'github://SeasideSt/Seaside:master/repository';
					loads: #('Base' 'Core' 'JSON' 'Email' 'Javascript' 'JQuery' 'Zinc' 'Filesystem' 'Development') ].

			spec baseline: 'OSSubprocess' with: [
				spec repository: 'github://pharo-contributions/OSSubprocess:master/repository' ].

"			spec baseline: 'RenoirSt' with: [
				spec
					repository: 'github://ba-st/RenoirSt:release-candidate';
					loads: #('Development') ]."

			spec package: 'MCL-Utils-Blankness' with: [
				spec repository: 'github://talk-small-be-open/utils:master/src'
			].
				
			spec package: 'MCLSmalltalkTemplate' with: [
				spec repository: 'github://talk-small-be-open/utils:master/src'
			].
	
			spec
				package: 'GemstoneServerCockpit' with: [
					spec requires: #('Seaside3' 'OSSubprocess' "'RenoirSt'" 'MCL-Utils-Blankness' 'MCLSmalltalkTemplate') ].
		].
	
	spec
		group: 'default' with: #('Core');
		group: 'Core' with: #('GemstoneServerCockpit')
]

{ #category : #baselines }
BaselineOfGemstoneServerCockpit >> projectClass [
	^ MetacelloCypressBaselineProject
]
