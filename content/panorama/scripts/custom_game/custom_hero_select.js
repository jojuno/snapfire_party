var heroIndex = 0;
var hero_details = [
  {
    name: "#npc_dota_hero_chen",
  },
  {
    name: "#npc_dota_hero_mirana",
  },
  {
    name: "#npc_dota_hero_batrider",
  },
  {
    name: "#npc_dota_hero_gyrocopter",
  },
  {
    name: "#npc_dota_hero_luna",
  },
  {
    name: "#npc_dota_hero_disruptor",
  },
  {
    name: "#npc_dota_hero_keeper_of_the_light",
  },
  {
    name: "#npc_dota_hero_snapfire",
  },
];

function OnSelectionEnd() {
  HideHeroSelection();
}

function OnHighlightHero(index) {
  heroIndex = index;

  var hero_detail = hero_details[index];
  $("#HeroName").text = $.Localize(hero_detail.name);
  //because this doesn't work, it prevents the box from being highlighted
  //for (var i = 0; i < 5; i++) {
  //  $("#HeroAbility" + i).abilityname = hero_detail.abilities[i].icon;
  //}

  //use Object.keys(hero_details).length to make it dynanic to the length of the "hero_details" dictionary
  for (var i = 0; i < Object.keys(hero_details).length; i++) {
    if (i == index) {
      $("#HeroImage" + index).style["backgroundColor"] = "#FFD700";
    } else {
      $("#HeroImage" + i).style["backgroundColor"] = "#000000";
    }
  }
}

function OnMouseOver(index) {
  $.DispatchEvent(
    "DOTAShowAbilityTooltip",
    $("#HeroAbility" + index),
    hero_details[heroIndex].abilities[index].name
  );
}

function OnMouseOut(index) {
  $.DispatchEvent("DOTAHideAbilityTooltip");
}

function OnHeroMouseOver(index) {
  $.DispatchEvent(
    "DOTAShowTitleTextTooltip",
    $("#HeroImage" + index),
    $.Localize(hero_details[index].name),
    $.Localize(hero_details[index].name + "_lore")
  );
}

function OnHeroMouseOut(index) {
  $.DispatchEvent("DOTAHideTitleTextTooltip");
}

function OnSelectHero() {
  var hero_names = [
    "npc_dota_hero_chen",
    "npc_dota_hero_mirana",
    "npc_dota_hero_batrider",
    "npc_dota_hero_gyrocopter",
    "npc_dota_hero_luna",
    "npc_dota_hero_disruptor",
    "npc_dota_hero_keeper_of_the_light",
    "npc_dota_hero_snapfire",
  ];

  var payload = {
    hero_name: hero_names[heroIndex],
  };

  // $.Msg("payload: " + JSON.stringify(payload));

  GameEvents.SendCustomGameEventToServer("js_player_select_hero", payload);

  Game.EmitSound("Conquest.capture_point_timer.Generic");
}

function HideHeroSelection() {
  $("#HeroSelectRoot").visible = false;
}

function ShowHeroSelection() {
  $("#HeroSelectRoot").visible = true;
}

(function () {
  GameEvents.Subscribe("hero_selection_end", OnSelectionEnd);
  OnHighlightHero(heroIndex);

  var localPlayer = Game.GetLocalPlayerInfo();
  if (localPlayer) {
    var selectedHero = localPlayer.player_selected_hero;
    if (selectedHero) {
      if (selectedHero === "npc_dota_hero_snapfire") {
      } else {
        // HideHeroSelection();
      }
    }
  }
})();
