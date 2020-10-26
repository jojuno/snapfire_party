var cookieGodIndex = 0;

var cookie_god_details = [
  {
    name: "axe",
  },
  {
    name: "bristleback",
  },
  {
    name: "crystal_maiden",
  },
  {
    name: "invoker",
  },
  {
    name: "ogre",
  },
  {
    name: "jugg",
  },
  {
    name: "lina",
  },
  {
    name: "mortimer",
  }
]


function OnSpecialGameEnd() {
  AddCookieGods();
  OnHighlightCookieGod(cookieGodIndex);
  //AddAbilities();
}

function AddCookieGods() {
  var panel = $.CreatePanel("Panel", $("#SelectionPanel"), "");
  
  panel.BLoadLayoutSnippet("CookieGodSnippet");
  panel.FindChildTraverse("CookieGodImage0").SetScaling("50")
  panel.FindChildTraverse("CookieGodImage4").SetScaling("50")
  //if player hasn't chosen a god after 10 seconds, assign random god and make the panel disappear
}

function AddAbilities() {
  var panel = $.CreatePanel("Panel", $("#AbilityPanel"), "");
  panel.BLoadLayoutSnippet("CookieGodAbilitySnippet");
  //if player hasn't chosen a god after 10 seconds, assign random god and make the panel disappear
}

function OnSelectCookieGod() {
  var cookie_god_names = [
    "axe",
    "bristleback",
    "crystal_maiden",
    "invoker",
    "jugg",
    "lina",
    "ogre",
    "mortimer"
  ];
  var payload = {
    cookie_god_name: cookie_god_names[cookieGodIndex],
  };
  GameEvents.SendCustomGameEventToServer(
    "js_player_select_cookie_god",
    payload
  );
  //emit cool sound
}

function OnCookieGodSelectionEnd() {
  HideCookieGodSelection();
  //HideCookieGodAbilities();
}

function HideCookieGodSelection() {
  $("#CookieGodSelectRoot").visible = false;
}

function HideCookieGodAbilities() {
  $("#CookieGodAbilitiesRoot").visible = false;
}

function OnHighlightCookieGod(index) {
  cookieGodIndex = index;
  var cookie_god_detail = cookie_god_details[cookieGodIndex];
  //need # for id
  $("#CookieGodName").text = $.Localize(cookie_god_detail.name);
  for (var i = 0; i < Object.keys(cookie_god_details).length; i++) {
    if (i == cookieGodIndex) {
      $("#CookieGodImage" + index).style["backgroundColor"] = "#FFD700";
    } else {
      $("#CookieGodImage" + i).style["backgroundColor"] = "#000000";
    }
  }
}

//fill in abilities here
function OnCookieGodMouseOver(index) {
  $.DispatchEvent(
    "DOTAShowTitleTextTooltip",
    $("#CookieGodImage" + index),
    $.Localize(cookie_god_details[index].name),
    $.Localize(cookie_god_details[index].name + "_lore")
  );
}

function OnCookieGodMouseOut(index) {
  $.DispatchEvent("DOTAHideTitleTextTooltip");
}

function RunSelectCookieGod() {
  GameEvents.Subscribe("special_game_end", OnSpecialGameEnd);
  GameEvents.Subscribe("cookie_god_selection_end", OnCookieGodSelectionEnd);
}
RunSelectCookieGod();
