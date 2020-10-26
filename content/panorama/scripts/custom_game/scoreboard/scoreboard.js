//$.GetContextPanel().SetHasClass("Scoreboard", false);

function AddDebugScore(color) {
  //Make the panel
  var panel = $.CreatePanel("Panel", $("#Scores"), "");
  panel.BLoadLayoutSnippet("Score");

  panel.FindChildTraverse("ScoreTitle").text = " The Score of Pink Team";
  panel.FindChildTraverse("ScoreDescription").text = "Number of Rounds Won";
  //panel.FindChildTraverse("ScoreProgress").text = "3/7";
  SetScoreProgress(panel, 3, 7);
}

function SetScoreProgress(score, current, goal) {
  var percent = current / goal;
  score.FindChildTraverse("ScoreProgress").text = current + "/" + goal;
  var background = score.FindChildTraverse("Background");
  background.style.width = percent * 100 + "%";
}

function InitQuest(name, description, target) {
  var panel = $.CreatePanel("Panel", $("#Scores"), "");
  panel.BLoadLayoutSnippet("Score");

  panel.FindChildTraverse("ScoreTitle").text = name;
  panel.FindChildTraverse("ScoreDescription").text = description;

  panel.name = name;
  panel.desc = description;

  SetScoreProgress(panel, 0);
}

function debug() {
  $.Msg("Debug!");
  AddDebugScore("red");
}

debug();
