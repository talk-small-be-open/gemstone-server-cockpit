Class {
	#name : #GSCRootSchemeV1,
	#superclass : #GSCRootScheme,
	#category : #'GemstoneServerCockpit-Model'
}

{ #category : #'as yet unclassified' }
GSCRootSchemeV1 >> buildRootTool [
	| root |

	root := GSCRoot new.
	root scheme: self.
	root build.

	root add: GSCFolder then: [ :folder |
		folder name: 'Server software'.

		"hardcoded apt packages for the server setup"
		"'mailutils' ""for ngxblocker to send emails"""
		{'logrotate'. 'ufw'. 'git'. 'htop'. 'unzip'. 'zip'. 'pigz'. 'aptitude'. 'mosh'.
		'cronic'. 'goaccess'. 'lnav'. 'ansible'. 'snapd' } do: [ :each |
			folder add: GSCAptPackage then: [ :apt |
				apt packageName: each ] ].
		
		"additional apt packages from the config"
		(config at: 'server:aptPackages') do: [ :each |
			folder add: GSCAptPackage then: [ :apt |
				apt packageName: each ] ].

		folder add: GSCSnapPackage then: [ :apt |
			apt packageName: 'certbot' ].
	].
	
	root add: GSCNginx.
	
	root add: GSCHaproxy.
	
	root add: GSCMonit.
	
	root add: GSCGsDevKit.

	root add: GSCAnsibleTasks then: [ :ansible |
		ansible addTasksJson: '
[
    {
        "name": "Set timezone to Switzerland",
        "timezone": {
            "name": "Europe/Zurich"
        }
    }
]
'
	].

	root add: GSCFolder then: [ :folder |
		folder name: 'Utilities'.

		folder add: GSCShellConsole.
		folder add: GSCGeneralTool then: [ :tool |
			tool actionBlock: [ GSCCore instance clearSudoPassword ].
			tool title: 'reset sudo'
	].	].

	^ root
]
