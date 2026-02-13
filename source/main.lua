import 'libraries/noble/Noble'

import 'utilities/GameConstants'
import 'utilities/Utilities'
import 'utilities/Sound'
import 'utilities/Shaker'


import 'scenes/TitleScene'
import 'scenes/GameScene'
import 'scenes/SettingsScene'
import 'scenes/CreditsScene'
import 'scenes/TutorialScene'
import 'scenes/InitialsPostScene'
import 'scenes/TitleScene2'


Noble.Settings.setup({
	soundEnabled = true,
	musicEnabled = true,
	Difficulty = "Easy", -- delete this?
	Highscore1 = 666,
	Initials1 = "DVL",
	Highscore2 = 420,
	Initials2 = "BOB",
	Highscore3 = 369,
	Initials3 = "NIC",
	Highscore4 = 139,
	Initials4 = "VFC",
	Highscore5 = 46,
	Initials5 = "SXE",
	Initials = "---",
}

)

Noble.GameData.setup({
	Score = 0, -- distance to be tracked
	LastScore = 0, -- last score to be used in post scene
	HighScoreRank = 0, -- rank of the last score
})


Noble.showFPS = false -- can stay here as false, toggle true for testing FPS


-- font stuff
FONT_PIXO = Graphics.font.new("assets/fonts/pixel-pixo-sm")
FONT_PIXO_SMOL = Graphics.font.new("assets/fonts/pixel-pixo-test1")

Noble.Text.setFont(FONT_PIXO) -- set font. Do we need it?


-- Ensure settings are explicitly set at game start
Noble.Settings.set("soundEnabled", true)
Noble.Settings.set("musicEnabled", true)

-- disable undocking crank sound
playdate.setCrankSoundsDisabled(true)


-- Initialize sound system after settings so defaults are applied
Sound.init()
Sound.playMusic("chesty1")

Noble.new(TitleScene)