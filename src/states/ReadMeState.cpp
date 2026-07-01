#include "ReadMeState.hpp"
#include "Constants.hpp"
#include "helpers/Audio.hpp"
#include "helpers/Graphics.hpp"
#include "helpers/InputAction.hpp"
#include <string>

static constexpr int PAGE_COUNT = 8;

// Draws an image stretched into a 48x48 box at (x, y), like the original MyStretchDraw.
static void stretch_draw(const Gosu::Image& image, int x, int y)
{
    image.draw(x, y, Z_UI, 48.0 / image.width(), 48.0 / image.height());
}

// A glowing additive fire overlay, used for Feuerpeter and the burning enemy.
static void fire(int index, double x, double y)
{
    const Gosu::Image& image = effect_image(index);
    image.draw(x, y, Z_UI, 48.0 / image.width(), 48.0 / image.height(),
               Gosu::Color::WHITE.with_alpha(192), Gosu::BM_ADD);
}

ReadMeState::ReadMeState()
    : m_title_image("assets/TitleDark.png")
{
}

void ReadMeState::update()
{
    play_song("Menu");
}

void ReadMeState::draw()
{
    m_title_image.draw(0, 0);

    switch (m_page) {
    case 0:
        draw_bmp_text("Willkommen bei Peter Morphose!", 20, 20);
        draw_bmp_text("Hier findest du die Erklärung des Spielprinzips, der Steuerung und", 20, 60);
        draw_bmp_text("der Objekte und Kartenteile, die du im Spiel triffst.", 20, 80);
        // Removed obsolete reference to the Ritter theme - additional themes never materialized.
        draw_bmp_text("Die Steuerung: (Gamepad oder Tastatur)", 20, 180);
        draw_bmp_text("Pfeiltasten links/rechts:   Laufen", 20, 220);
        draw_bmp_text("Pfeiltaste rauf/Button 1:   Springen", 20, 240);
        draw_bmp_text("Leertaste/Button 2:         Spezialaktion des aktuellen Peters", 20, 260);
        draw_bmp_text("Pfeiltaste runter/Button 3: Treppen und Bodenplatten benutzen", 20, 280);
        draw_bmp_text("Enter/Entfernen/Button 4:   Wieder zum normalen Peter werden", 20, 300);
        draw_bmp_text("P:                          Pause an/aus", 20, 320);
        draw_bmp_text("Escape:                     Wieder zum Hauptmenü", 20, 340);
        break;

    case 1:
        draw_bmp_text("Weitere Tipps zur Steuerung:", 20, 20);
        draw_bmp_text("• Nur der normale Peter kann Hebel umlegen (Spezialaktion). Wenn du", 20,
                      60);
        draw_bmp_text("  ein Spezialpeter bist und einen Hebel umlegen willst, musst du", 20, 80);
        draw_bmp_text("  dich erst zurückverwandeln (Enter/B4).", 20, 100);
        draw_bmp_text("• Im Sprung kannst du die Flugrichtung ein wenig mit Links/Rechts", 20, 120);
        draw_bmp_text("  beeinflussen.", 20, 140);
        draw_bmp_text("• Wenn du getroffen wirst, bist du für etwa eine Sekunde transparent", 20,
                      160);
        draw_bmp_text("  und unverwundbar. Nutze die Zeit, um aus dem Getümmel zu entkommen!", 20,
                      180);
        draw_bmp_text("Ziel des Spiels ist es, durch die jeweils letzte nach oben führende", 20,
                      220);
        draw_bmp_text("Treppe des Levels zu gehen. Wenn du genug Sterne hast, hast du das", 20,
                      240);
        draw_bmp_text("Level geschafft. In vielen Runden muss man unterwegs auch eine oder", 20,
                      260);
        draw_bmp_text("mehrere Geiseln retten (berühren), um gewinnen zu können. Das Ziel", 20,
                      280);
        draw_bmp_text("einer Runde siehst du vor dem Spielen im Levelauswahlbildschirm.", 20, 300);
        draw_bmp_text("Was dich daran hindert, durch das Level zu kommen, ist vor allem", 20, 320);
        draw_bmp_text("die Lava, die unerbittlich steigt und alles auf ihrem Wege toastet.", 20,
                      340);
        draw_bmp_text("Aber auch einige Gegner und Rätsel stehen dir im Weg...", 20, 360);
        break;

    case 2:
        draw_bmp_text("Die 5 verschiedenen Peter:", 20, 20);
        stretch_draw(player_image(ID_PLAYER, DIR_RIGHT, ACT_STAND), 20, 50);
        draw_bmp_text("Das ist der normale Peter. Er ist wendig und kann Hebel", 80, 60);
        draw_bmp_text("umlegen (Leertaste/B2).", 80, 80);
        stretch_draw(player_image(ID_PLAYER_FIGHTER, DIR_LEFT, ACT_ACTION_3), 20, 100);
        draw_bmp_text("Ritterpeter ist stabiler und träger als Peter. Er kann dafür", 80, 110);
        draw_bmp_text("mit dem Schwert zuschlagen (Leertaste/B2).", 80, 130);
        stretch_draw(player_image(ID_PLAYER_GUN, DIR_RIGHT, ACT_STAND), 20, 150);
        draw_bmp_text("Das ist Flitzebogenpeter. Er kann auf der Leertaste schießen,", 80, 160);
        draw_bmp_text("verbraucht allerdings Munition.", 80, 180);
        stretch_draw(player_image(ID_PLAYER_BOMBER, DIR_RIGHT, ACT_STAND), 20, 200);
        draw_bmp_text("Der Bombenlegerpeter kann Bomben werfen (Leertaste) und damit", 80, 210);
        draw_bmp_text("Gegner bekämpfen und Sprengstoffkisten explodieren lassen.", 80, 230);
        fire(8, 20, 250);
        stretch_draw(player_image(ID_PLAYER_BERSERKER, DIR_RIGHT, ACT_STAND), 20, 250);
        draw_bmp_text("Feuerpeter hat keine Spezialaktion. Er ist beinahe", 80, 260);
        draw_bmp_text("unverwundbar und kann Gegner durch Berührung töten.", 80, 280);
        stretch_draw(object_image(ID_MUNITION_BOMBER_2), 10, 300);
        stretch_draw(object_image(ID_MUNITION_GUN_2), 20, 310);
        draw_bmp_text("Pfeile sind Munition für den Flitzebogenpeter, Bomben für", 80, 310);
        draw_bmp_text("Bombenlegerpeter.", 80, 330);
        break;

    case 3:
        draw_bmp_text("Die 5 verschiedenen Gegner:", 20, 20);
        stretch_draw(enemy_image(ID_ENEMY, DIR_LEFT, ACT_STAND), 580, 50);
        draw_bmp_text("Kinderschrecks sind schwache, schnelle Gegner und meistens", 20, 60);
        draw_bmp_text("keine große Gefahr.", 20, 80);
        stretch_draw(enemy_image(ID_ENEMY_FIGHTER, DIR_RIGHT, ACT_ACTION_4), 580, 100);
        draw_bmp_text("Tempelwächter sind zwar langsam, halten aber mehr Schläge aus", 20, 110);
        draw_bmp_text("als Kinderschrecks.", 20, 130);
        stretch_draw(enemy_image(ID_ENEMY_BOMBER, DIR_LEFT, ACT_STAND), 580, 150);
        draw_bmp_text("Diese schnellen Gegner explodieren bei Kontakt mit Peter und", 20, 160);
        draw_bmp_text("ziehen ihm so viel Energie ab. Gefährlich!", 20, 180);
        stretch_draw(enemy_image(ID_ENEMY_GUN, DIR_LEFT, ACT_STAND), 580, 200);
        draw_bmp_text("Bogenbayern lauern meistens an schwer erreichbaren Orten und", 20, 210);
        draw_bmp_text("schießen auf Peter, sobald sie ihn sehen.", 20, 230);
        fire(7, 580, 255);
        stretch_draw(enemy_image(ID_ENEMY_BERSERKER, DIR_RIGHT, ACT_STAND), 580, 250);
        draw_bmp_text("Diese brennenden Unholde lassen sich am besten aus der Distanz", 20, 260);
        draw_bmp_text("besiegen. Kontakt meiden!", 20, 280);
        break;

    case 4:
        draw_bmp_text("Die wichtigsten Objekte:", 20, 20);
        stretch_draw(object_image(ID_HOSTAGE), 20, 50);
        draw_bmp_text("Eine arme Gefangene. Muss durch Berührung gerettet werden.", 80, 60);
        draw_bmp_text("Stirbt sie, ist das Spiel sofort verloren!", 80, 80);
        stretch_draw(object_image(ID_KEY), 20, 100);
        draw_bmp_text("Manche Türen kann man nur öffnen, wenn man noch einen", 80, 110);
        draw_bmp_text("Schlüssel übrig hat.", 80, 130);
        stretch_draw(object_image(ID_STAR), 15, 140);
        stretch_draw(object_image(ID_STAR_2), 20, 150);
        stretch_draw(object_image(ID_STAR_3), 25, 160);
        draw_bmp_text("Diese Sterne müssen meistens in einer bestimmten Anzahl", 80, 160);
        draw_bmp_text("eingesammelt werden, damit man die Runde schaffen kann.", 80, 180);
        stretch_draw(object_image(ID_HEALTH), 25, 195);
        stretch_draw(object_image(ID_EDIBLE_FISH_RIGHT), 20, 210);
        draw_bmp_text("Kleine Beeren füllen eine Energie auf, große vier. Rote", 80, 210);
        draw_bmp_text("Fische füllen immer nur eine Energie auf.", 80, 230);
        stretch_draw(object_image(ID_MORPH_FIGHTER), 20, 250);
        draw_bmp_text("Morphobjekte verwandeln Peter in den abgebildeten", 80, 260);
        draw_bmp_text("Spezialpeter (hier: Ritterpeter).", 80, 280);
        stretch_draw(object_image(ID_MORE_TIME), 25, 295);
        stretch_draw(object_image(ID_MORE_TIME_2), 15, 310);
        draw_bmp_text("Große und kleine Uhren geben ein paar Sekunden mehr", 80, 310);
        draw_bmp_text("Spezialpeterzeit.", 80, 330);
        break;

    case 5:
        draw_bmp_text("Weitere wichtige Objekte:", 20, 20);
        stretch_draw(object_image(ID_LEVER), 25, 40);
        stretch_draw(object_image(ID_LEVER_RIGHT), 25, 90);
        draw_bmp_text("Hebel und Schalter kann nur der normale Peter umlegen", 80, 60);
        draw_bmp_text("(Leertaste). Sie verändern normalerweise etwas an der", 80, 80);
        draw_bmp_text("Spielwelt (Spezialteil erscheint, Mauer verschwindet,", 80, 100);
        draw_bmp_text("Hilfsobjekte werden erschaffen...).", 80, 120);
        stretch_draw(object_image(ID_SLOW_DOWN), 25, 145);
        stretch_draw(object_image(ID_CRYSTAL), 15, 165);
        draw_bmp_text("Sanduhren machen die Lava dauerhaft langsamer, Kristalle", 80, 160);
        draw_bmp_text("frieren sie wenige Sekunden lang ein.", 80, 180);
        stretch_draw(object_image(ID_FLY), 20, 200);
        draw_bmp_text("Mit diesen Flügeln kann Peter fliegen, bis sie vollständig", 80, 210);
        draw_bmp_text("verblasst sind.", 80, 230);
        stretch_draw(object_image(ID_JUMP), 27, 242);
        stretch_draw(object_image(ID_SPEED), 13, 258);
        draw_bmp_text("Siebenmeilenstiefel lassen Peter eine Weile schneller", 80, 260);
        draw_bmp_text("laufen, Adlerstiefel höher springen.", 80, 280);
        stretch_draw(object_image(ID_POINTS_MAX), 28, 318);
        stretch_draw(object_image(ID_POINTS), 5, 290);
        stretch_draw(object_image(PMID(ID_POINTS + 4)), 5, 315);
        stretch_draw(object_image(PMID(ID_POINTS + 1)), 25, 290);
        stretch_draw(object_image(PMID(ID_POINTS + 3)), 15, 300);
        stretch_draw(object_image(PMID(ID_POINTS + 2)), 20, 310);
        draw_bmp_text("Diese Objekte machen nichts Anderes als Punkte zu geben.", 80, 310);
        draw_bmp_text("Nur einsammeln, wenn du zu viel Zeit hast!", 80, 330);
        break;

    case 6:
        draw_bmp_text("Die wichtigsten Spezialkartenteile:", 20, 20);
        stretch_draw(tile_image(TILE_ROCKET_UP_LEFT_2), 20, 55);
        draw_bmp_text("Katapultiert den Spieler bei Aktivierung (Pfeiltaste unten)", 80, 60);
        draw_bmp_text("in Richtung des Pfeiles (hier: oben links).", 80, 80);
        stretch_draw(tile_image(TILE_MORPH_BOMB), 20, 105);
        draw_bmp_text("Verwandelt den Spieler bei Aktivierung in den abgebildeten", 80, 110);
        draw_bmp_text("Spezialpeter (hier: Bombenlegerpeter).", 80, 130);
        stretch_draw(tile_image(TILE_CLOSED_DOOR_3), 20, 155);
        draw_bmp_text("Diese Türen lassen sich nur öffnen, wenn man einen Schlüssel", 80, 160);
        draw_bmp_text("dabei hat.", 80, 180);
        stretch_draw(tile_image(TILE_BLOCKER), 20, 205);
        draw_bmp_text("Lassen sich mit Ritterpeter zerschlagen und mit Bombenleger-", 80, 210);
        draw_bmp_text("peter zerbomben.", 80, 230);
        stretch_draw(tile_image(TILE_BIG_BLOCKER), 20, 255);
        draw_bmp_text("Kann mit einer Bombe angezündet werden. Explodiert dann und", 80, 260);
        draw_bmp_text("kann dabei auch weitere Kisten anzünden... Kettenreaktion!", 80, 280);
        stretch_draw(tile_image(TILE_BRIDGE_2), 20, 305);
        draw_bmp_text("Diese alten, verwitterten Steinmauern fangen an, zu zer-", 80, 310);
        draw_bmp_text("bröseln, sobald ein Lebewesen draufläuft.", 80, 330);
        break;

    case 7:
        draw_bmp_text("Mehr Spezialkartenteile:", 20, 20);
        stretch_draw(tile_image(TILE_BIG_BLOCKER_3), 20, 55);
        draw_bmp_text("Lässt sich auch zersprengen, explodiert aber nicht", 80, 60);
        draw_bmp_text("selbst, im Gegensatz zu Sprengstoffkisten.", 80, 80);
        stretch_draw(tile_image(TILE_SLIME_2), 20, 105);
        draw_bmp_text("Auf diesem klebrigen Schleim kann Peter nur sehr", 80, 110);
        draw_bmp_text("langsam laufen und nicht hoch springen.", 80, 130);
        stretch_draw(tile_image(TILE_STAIRS_UP), 20, 155);
        draw_bmp_text("Geht man in eine solche Tür, kommt man aus der nächsten", 80, 160);
        draw_bmp_text("Tür in Richtung des Pfeiles raus. Kann verschlossen sein.", 80, 180);
        stretch_draw(tile_image(TILE_AIR_ROCKET_UP_2), 20, 205);
        draw_bmp_text("Läuft man an diesen Kartenteilen vorbei, schleudern sie", 80, 210);
        draw_bmp_text("den Spieler in die angezeigte Richtung.", 80, 230);
        stretch_draw(tile_image(TILE_SPIKES), 20, 255);
        draw_bmp_text("Diese Stacheln sind unangenehm für Gegner und Spieler.", 80, 260);
        draw_bmp_text("Manchmal auch an der Decke zu finden.", 80, 280);
        draw_bmp_text("So, und jetzt noch viel Glück und Spaß beim Spielen von", 80, 335);
        draw_bmp_text("Peter Morphose!", 230, 360);
        break;
    }

    // Common footer with the page number, on every page.
    draw_bmp_text("Mit den Pfeiltasten kannst du in der Hilfe blättern. (Seite "
                      + std::to_string(m_page + 1) + " von " + std::to_string(PAGE_COUNT) + ")",
                  14, 424, 200);
    draw_bmp_text("Auf Escape kommst du zum Hauptmenü zurück.", 131, 446, 200);
}

void ReadMeState::button_down(Gosu::Button id)
{
    if (is_mapped_to(InputAction::MenuPrev, id) && m_page > 0) { // up / left
        m_page -= 1;
    }
    if (is_mapped_to(InputAction::MenuNext, id) && m_page < PAGE_COUNT - 1) { // down / right
        m_page += 1;
    }
    if (is_mapped_to(InputAction::MenuCancel, id)) {
        play_sound("WooshBack");
        pop_state(); // back to main menu
    }
}
