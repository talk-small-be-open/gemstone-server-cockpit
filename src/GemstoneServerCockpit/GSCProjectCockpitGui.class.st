Class {
	#name : #GSCProjectCockpitGui,
	#superclass : #SpPresenter,
	#instVars : [
		'menu',
		'output'
	],
	#category : #GemstoneServerCockpit
}

{ #category : #'user interface' }
GSCProjectCockpitGui class >> menuExamplesOn: aBuilder [
	"Add a custom menu item to the world menu"

	<worldMenu>
	(aBuilder item: #GSC)
		order: 1;
		help: 'Open GSC Cockpit'.

	(aBuilder item: #'GSC Cockpit')
"		iconName: #smallHelpIcon;"
		parent: #GSC;
		order: 1;
		help: 'Open GSC Cockpit';
		action: [ self open ].

"	aBuilder withSeparatorAfter"
]

{ #category : #'instance creation' }
GSCProjectCockpitGui class >> on: aModel [

	^ self basicNew 
		model: aModel;
		initialize;
		yourself.
]

{ #category : #specs }
GSCProjectCockpitGui class >> open [
	<example>
	
	^ self new
		openWithSpec
]

{ #category : #accessing }
GSCProjectCockpitGui >> addItemTo: aGroup [
	aGroup
		addItem: [ :item | 
			item
				name: 'Dynamic';
				icon: (self iconNamed: #delete);
				action: [ aGroup menuItems remove: item.
					self needRebuild: false.
					self buildWithSpec ] ].
	self needRebuild: false.
	self buildWithSpec
]

{ #category : #initialization }
GSCProjectCockpitGui >> connectPresenters [

"	list selectItem: self selectedPage.
	list whenSelectionChangedDo: [ :selection | 
		selection selectedItem
			ifNotNil: [ :newPageClass | 
				newPageClass = self selectedPage
					ifFalse: [ 
						self selectedPage: newPageClass.
						page
							removeAll; 
							add: (self instantiate: newPageClass);
							yourself ] ]
			ifNil: [ 
				""Avoid the user to have no page selected at all."" 
				list setSelectedItem: self selectedPage ] ]"
]

{ #category : #api }
GSCProjectCockpitGui >> initialExtent [

	| fontWidth rowHeight |
	fontWidth := (StandardFonts defaultFont widthOfString: 'M').
	rowHeight := self class inputTextHeight.

	^ (90@24) * (fontWidth @ rowHeight)
	
]

{ #category : #initialization }
GSCProjectCockpitGui >> initializePresenters [

	menu := self mainMenu.

"	list := self newList."

	output := SpBoxLayout newTopToBottom 
		add: (self newTextInput
			placeholder: 'Enter a class name';
			removeEntryCompletion);
		yourself.

	self layout: (SpBoxLayout newTopToBottom
		add: menu expand: false;
		add: output;
"		add: (SpPanedLayout newLeftToRight
			positionOfSlider: 200;
			add: list;
			add: page;
			yourself);"
		yourself).

	menu addKeybindingsTo: self.

"	list
		items: self availablePages;
		display: [ :item | item pageName ];
		contextMenu:
			(self newMenu
				addItem: [ :item | 
					item
						name: 'Browse';
						icon: (self iconNamed: #smallHelp);
						action: [ list selectedItem browse ] ];
				addItem: [ :item | 
					item
						name: 'Browse presenter';
						icon: (self iconNamed: #smallHelp);
						action: [ list selectedItem new pageClass browse ] ];
				yourself)."

"	self focusOrder
		add: list;
		addAll: page presenters" 
]

{ #category : #initialization }
GSCProjectCockpitGui >> mainMenu [
	| aMenu |
	aMenu := self newMenuBar
		addGroup: [ :group | 
			group
				addItem: [ :item | 
					item
						name: 'File';
						icon: (self iconNamed: #openIcon);
						subMenu: self subMenu ].
			group
				addItem: [ :item | 
					item
						name: nil;
						description: 'Open file';
						icon: (self iconNamed: #openIcon);
						action: [ self inform: 'Open File' ] ].
			group
				addItem: [ :item | 
					item
						name: nil;
						description: 'Save File';
						icon: (self iconNamed: #smallSaveIcon);
						action: [ self inform: 'Save File' ] ].
			group
				addItem: [ :item | 
					item
						name: nil;
						description: 'Print file';
						icon: (self iconNamed: #smallPrintIcon);
						action: [ self inform: 'Print file' ] ] ];
		addGroup: [ :group | 
			group
				addItem: [ :item | 
					item
						name: nil;
						description: 'Undo';
						icon: (self iconNamed: #smallUndoIcon);
						action: [ self inform: 'Undo' ] ].
			group
				addItem: [ :item | 
					item
						name: nil;
						description: 'Redo';
						icon: (self iconNamed: #smallRedoIcon);
						action: [ self inform: 'Redo' ] ] ];
		addGroup: [ :group | 
			group
				addItem: [ :item | 
					item
						name: nil;
						description: 'Add menu item';
						icon: (self iconNamed: #add);
						action: [ self addItemTo: group ] ] ].
	^ aMenu
]

{ #category : #accessing }
GSCProjectCockpitGui >> menu [
	^ menu
]

{ #category : #accessing }
GSCProjectCockpitGui >> menu: anObject [
	menu := anObject
]

{ #category : #initialization }
GSCProjectCockpitGui >> subMenu [
	^ self newMenu
		addItem: [ :item | 
			item
				name: 'Open';
				icon: (self iconNamed: #openIcon);
				shortcut: $o meta;
				action: [ self inform: 'Open' ] ];
		addItem: [ :item | 
			item
				name: 'Save';
				icon: (self iconNamed: #smallSaveIcon);
				shortcut: $s meta;
				action: [ self inform: 'Save' ] ];
		addItem: [ :item | 
			item
				name: 'Print';
				shortcut: $p meta;
				icon: (self iconNamed: #smallPrintIcon);
				action: [ self inform: 'Print' ] ];
		addItem: [ :item | 
			item
				name: 'Close';
				shortcut: $c meta;
				icon: (self iconNamed: #smallCancelIcon);
				action: [ self inform: 'Kill' ] ];
		yourself
]

{ #category : #api }
GSCProjectCockpitGui >> title [
	
	^ 'GSC Cockpit'.
]
