/**
 * Sketch mit Scroll/Zoom und zusätzlichem Overview-Track oben.
 * Die abgelaufene Zeit wird anhand von Ticks+BPM berechnet.
 * Alle ternären Operatoren sind in if/else umgewandelt.
 */

import hypermedia.net.*;
import processing.data.*;

final int TICKS_PER_BEAT = 24;  // 24 Ticks pro Schlag

// Haupt-Timeline
final float TRACK_HEIGHT_ROLES  = 30;   // Höhe pro Rolle (Gregor/Ali/Frank)
final float TRACK_HEIGHT_PARAMS = 30;  // Höhe für Parameter-Säulen
final float TRACK_GAP           = 15;   // Abstand zwischen Spuren
final float TRACK_RP_GAP        = 45;
final float LEFT_MARGIN         = 120;  // Platz links für Labels
final float RIGHT_MARGIN        = 20;   // Platz rechts
float pixelsPerTick             = 0.2;  // Zoom-Faktor: Pixel pro Tick
final float PLAYHEAD_FRACTION   = 1.0/4.0; // Cursor-Position (ein Drittel)

// Overview-Track (volle Länge)
final float OVERVIEW_TOP        = 100;   // y-Position
final float OVERVIEW_HEIGHT     = 10;   // Höhe der Linie
final float OVERVIEW_LEFT_MARGIN  = 20;
final float OVERVIEW_RIGHT_MARGIN = RIGHT_MARGIN;

int dispX = 800;
int dispY = 520;

// Farben Rollen
color COLOR_HARMONIE = color(50, 150, 50);
color COLOR_SOLO     = color(150, 50, 50);
color COLOR_BEAT     = color(50, 50, 150);

// Farben Parameter (fest, Wert bestimmt alpha/Höhe)
color COLOR_KOMPLEX     = color(100, 50, 100);  // Lila
color COLOR_DISSONANZ   = color(50, 100, 200);    // Blau
color COLOR_INTENSITAET = color(150, 100, 50);  // Orange

// Farbe Hintergrund
color COLOR_BCKGND = color(20, 20, 20);

// Soll die Säulenhöhe vom Parameter abhängen (0..10)?
boolean useHeightForParam = true;

// Globale Variablen
UDP udp;
int currentTick = 0;
Segment[] segments;

void settings() {
  size(dispX, dispY);
}
// -----------------------------------------------------------------------------
void setup() {
  // Segmente laden
  loadSegmentsFromJson("segments.json");

  // UDP-Init (Port 8099)
  udp = new UDP(this, 8099);
  udp.log(true);
  udp.listen(true);

  println("Lausche auf UDP-Port 8099...");
}

void draw() {
  background(COLOR_BCKGND);

  // 1) Berechne abgelaufene Zeit (auf Basis Ticks & BPM)
  float elapsedSec = computeElapsedTimeSec(currentTick);
  int mm = floor(elapsedSec / 60);
  int ss = floor(elapsedSec % 60);
  String timeStr = nf(mm, 2) + ":" + nf(ss, 2);

  // 2) Bestimme Takt & Zählzeit
  int currentMeasure = 0;
  int currentBeat    = 0;
  String currTimeSig = "";
  String currTonart  = "";
  int currTempo      = 0;

  Segment seg = getCurrentSegment(currentTick);
  if (seg != null) {
    int localTicks = currentTick - seg.startTick;
    int beatsPerMeasure = parseTimeSignatureBeats(seg.timeSignature);
    int ticksPerMeasure = beatsPerMeasure * TICKS_PER_BEAT;

    int measureOffset = localTicks / ticksPerMeasure;
    int beatOffset    = (localTicks / TICKS_PER_BEAT) % beatsPerMeasure;

    currentMeasure = seg.absoluteStartMeasure + measureOffset + 1;
    currentBeat    = beatOffset + 1;

    currTimeSig = seg.timeSignature;
    currTonart  = seg.tonart;
    currTempo   = seg.tempo;
  }

  // 3) Kopfzeile
  fill(255);
  textSize(18);
  textAlign(LEFT, TOP);

  int maxTick = 0;
  if (segments.length > 0) {
    maxTick = segments[segments.length - 1].endTick;
  }

  // Anzeige Takt, Zählzeit, Taktart, Tonart, Tempo, Zeit
  String infoLine = "Takt: " + currentMeasure
    + "   Zählzeit: " + currentBeat
    + "   Taktart: " + currTimeSig
    + "   Tonart: " + currTonart
    + "   Tempo: " + currTempo + " BPM"
    + "   Zeit: " + timeStr;
  text(infoLine, 20, 20);



  // 5) Overview-Track (volle Länge)
  drawOverviewTrack();

  // 6) Scroll/Zoom für Haupt-Timeline
  float timelineWidth = width - LEFT_MARGIN - RIGHT_MARGIN;
  float playheadX = LEFT_MARGIN + timelineWidth * PLAYHEAD_FRACTION;
  float scrollBaseTick = currentTick - (playheadX - LEFT_MARGIN) / pixelsPerTick;

  // 7) Spuren
  float startY = OVERVIEW_TOP + 40;
  float nextY  = startY;

  float totalTracksHeight = 3*(TRACK_HEIGHT_ROLES + TRACK_GAP)
    + 3*(TRACK_HEIGHT_PARAMS + TRACK_GAP)
    - TRACK_GAP;

  // Takt-Raster
  drawMeasureGrid(scrollBaseTick, startY, startY + totalTracksHeight);

  // --- Rollen-Spuren ---
  
  drawRoleBars(scrollBaseTick, nextY, TRACK_HEIGHT_ROLES, "gregorRole");
  nextY += TRACK_HEIGHT_ROLES + TRACK_GAP;

  drawRoleBars(scrollBaseTick, nextY, TRACK_HEIGHT_ROLES, "aliRole");
  nextY += TRACK_HEIGHT_ROLES + TRACK_GAP;

  drawRoleBars(scrollBaseTick, nextY, TRACK_HEIGHT_ROLES, "frankRole");
  nextY += TRACK_HEIGHT_ROLES + TRACK_RP_GAP;

  // --- Parameter-Spuren ---
  drawParamColumnSingleColor(scrollBaseTick, nextY, TRACK_HEIGHT_PARAMS, "komplexitaet");
  nextY += TRACK_HEIGHT_PARAMS + TRACK_GAP;

  drawParamColumnSingleColor(scrollBaseTick, nextY, TRACK_HEIGHT_PARAMS, "dissonanz");
  nextY += TRACK_HEIGHT_PARAMS + TRACK_GAP;

  drawParamColumnSingleColor(scrollBaseTick, nextY, TRACK_HEIGHT_PARAMS, "intensitaet");
  nextY += TRACK_HEIGHT_PARAMS + TRACK_GAP;

  drawMargin(10, 10);
  nextY  = startY;
  drawTrackLabel("Gregor", 20, nextY + TRACK_HEIGHT_ROLES - 2);
  nextY += TRACK_HEIGHT_ROLES + TRACK_GAP;
  drawTrackLabel("Ali", 20, nextY + TRACK_HEIGHT_ROLES - 2);
  nextY += TRACK_HEIGHT_ROLES + TRACK_GAP;
  drawTrackLabel("Frank", 20, nextY + TRACK_HEIGHT_ROLES - 2);
  nextY += TRACK_HEIGHT_ROLES + TRACK_RP_GAP;
  drawTrackLabel("Komplexität", 20, nextY + TRACK_HEIGHT_PARAMS/2);
  nextY += TRACK_HEIGHT_PARAMS + TRACK_GAP;
  drawTrackLabel("Dissonanz", 20, nextY + TRACK_HEIGHT_PARAMS/2);
  nextY += TRACK_HEIGHT_PARAMS + TRACK_GAP;
  drawTrackLabel("Intensität", 20, nextY + TRACK_HEIGHT_PARAMS/2);




  // 8) Playhead in Haupt-Timeline
  drawPlayhead(playheadX);
    // 4) Legende
  drawLegend(LEFT_MARGIN, dispY-50);
}

// -----------------------------------------------------------------------------
// ZEICHEN-FUNKTIONEN

void drawOverviewTrack() {
  float overviewWidth = width - OVERVIEW_LEFT_MARGIN - OVERVIEW_RIGHT_MARGIN;
  int maxTick = 0;
  if (segments.length > 0) {
    maxTick = segments[segments.length - 1].endTick;
  }

  // Horizontale Linie
  stroke(200);
  strokeWeight(2);
  float yCenter = OVERVIEW_TOP + OVERVIEW_HEIGHT/2;
  line(OVERVIEW_LEFT_MARGIN, yCenter, OVERVIEW_LEFT_MARGIN + overviewWidth, yCenter);

  // Markierungen pro Segment
  textAlign(CENTER, BOTTOM);
  textSize(14);
  fill(255);

  for (int i = 0; i < segments.length; i++) {
    Segment s = segments[i];
    float xLine = map(s.startTick, 0, maxTick, OVERVIEW_LEFT_MARGIN, OVERVIEW_LEFT_MARGIN + overviewWidth);

    stroke(120);
    strokeWeight(1);
    line(xLine, OVERVIEW_TOP, xLine, OVERVIEW_TOP + OVERVIEW_HEIGHT);

    noStroke();
    text(""+(i+1), xLine, OVERVIEW_TOP - 2);
  }

  // Cursor
  float xCursor = map(currentTick, 0, maxTick, OVERVIEW_LEFT_MARGIN, OVERVIEW_LEFT_MARGIN + overviewWidth);
  stroke(255, 0, 0);
  strokeWeight(2);
  line(xCursor, OVERVIEW_TOP - 5, xCursor, OVERVIEW_TOP + OVERVIEW_HEIGHT + 5);
}

void drawLegend(float x, float y) {
  float boxSize = 20;
  float spacing = 100;
  textSize(18);
  textAlign(LEFT, TOP);

  fill(COLOR_HARMONIE);
  rect(x, y, boxSize, boxSize);
  fill(255);
  text("Harmonie", x + boxSize + 5, y + 2);

  fill(COLOR_SOLO);
  rect(x + spacing, y, boxSize, boxSize);
  fill(255);
  text("Solo", x + spacing + boxSize + 5, y + 2);

  fill(COLOR_BEAT);
  rect(x + 2*spacing, y, boxSize, boxSize);
  fill(255);
  text("Beat", x + 2*spacing + boxSize + 5, y + 2);
}

void drawMargin(float x, float y) {
  float boxSize = 20;
  float spacing = 100;
  fill(COLOR_BCKGND);
  rect(0, OVERVIEW_TOP+OVERVIEW_HEIGHT, LEFT_MARGIN, dispY);
  rect(dispX-RIGHT_MARGIN, OVERVIEW_TOP+OVERVIEW_HEIGHT, RIGHT_MARGIN, dispY);
}

void drawTrackLabel(String label, float x, float y) {
  fill(200);
  textSize(18);
  textAlign(LEFT, CENTER);
  text(label, x, y);
}

void drawPlayhead(float playheadX) {
  stroke(255, 0, 0);
  strokeWeight(2);
  line(playheadX, OVERVIEW_TOP + 35, playheadX, dispY - 60);
  strokeWeight(1);
}

void drawMeasureGrid(float scrollBaseTick, float topY, float bottomY) {
  stroke(80);
  strokeWeight(1);

  int maxTick = 0;
  if (segments.length > 0) {
    maxTick = segments[segments.length - 1].endTick;
  }

  for (Segment s : segments) {
    int beatsPerMeasure = parseTimeSignatureBeats(s.timeSignature);

    for (int m = 0; m <= s.measures; m++) {
      int measureTick = s.startTick + m * beatsPerMeasure * TICKS_PER_BEAT;
      float xLine = tickToX(measureTick, scrollBaseTick);

      if (xLine >= LEFT_MARGIN && xLine <= width - RIGHT_MARGIN) {
        line(xLine, topY, xLine, bottomY);
      }
    }
  }
}

// -----------------------------------------------------------------------------
// ROLLEN & PARAMETER-SPUREN

void drawRoleBars(float scrollBaseTick, float trackY, float trackHeight, String roleField) {
  noStroke();

  int maxTick = 0;
  if (segments.length > 0) {
    maxTick = segments[segments.length - 1].endTick;
  }

  for (Segment s : segments) {
    // Statt ternärem Operator => if/else
    String role;
    if (roleField.equals("gregorRole")) {
      role = s.gregorRole;
    } else if (roleField.equals("aliRole")) {
      role = s.aliRole;
    } else {
      role = s.frankRole;
    }

    if (role.equalsIgnoreCase("none")) {
      continue;
    }

    float sx = tickToX(s.startTick, scrollBaseTick);
    float ex = tickToX(s.endTick, scrollBaseTick);

    if (ex < LEFT_MARGIN || sx > (width - RIGHT_MARGIN)) {
      continue;
    }

    fill(getRoleColor(role));
    rect(sx, trackY, ex - sx, trackHeight);
  }
}

void drawParamColumnSingleColor(float scrollBaseTick, float trackY, float trackHeight, String paramField) {
  noStroke();

  int maxTick = 0;
  if (segments.length > 0) {
    maxTick = segments[segments.length - 1].endTick;
  }

  for (Segment s : segments) {
    int value = 0;
    if (paramField.equals("komplexitaet")) {
      value = s.komplexitaet;
    } else if (paramField.equals("dissonanz")) {
      value = s.dissonanz;
    } else {
      value = s.intensitaet;
    }
    value = constrain(value, 0, 10);

    color baseColor = getParamBaseColor(paramField);
    float alphaVal = map(value, 0, 10, 50, 255);
    alphaVal = 255;
    float sx = tickToX(s.startTick, scrollBaseTick);
    float ex = tickToX(s.endTick, scrollBaseTick);

    if (ex < LEFT_MARGIN || sx > (width - RIGHT_MARGIN)) {
      continue;
    }

    float colWidth = ex - sx;
    float colHeight;

    if (useHeightForParam) {
      colHeight = map(value, 0, 10, 0, trackHeight);
    } else {
      colHeight = trackHeight;
    }

    float sy = trackY + (trackHeight - colHeight);

    fill(red(baseColor), green(baseColor), blue(baseColor), alphaVal);
    rect(sx, sy, colWidth, colHeight);
  }
}

// -----------------------------------------------------------------------------
// HILFSFUNKTIONEN

float tickToX(float tick, float scrollBaseTick) {
  return LEFT_MARGIN + (tick - scrollBaseTick) * pixelsPerTick;
}

color getRoleColor(String role) {
  if (role.equalsIgnoreCase("Harmonie")) {
    return COLOR_HARMONIE;
  } else if (role.equalsIgnoreCase("Solo")) {
    return COLOR_SOLO;
  } else if (role.equalsIgnoreCase("Beat")) {
    return COLOR_BEAT;
  }
  return color(150);
}

color getParamBaseColor(String paramField) {
  if (paramField.equals("komplexitaet")) {
    return COLOR_KOMPLEX;
  } else if (paramField.equals("dissonanz")) {
    return COLOR_DISSONANZ;
  }
  return COLOR_INTENSITAET; // Intensität
}

// -----------------------------------------------------------------------------
// ZEIT & SEGMENT-BERECHNUNG

void receive(byte[] data, String ip, int port) {
  String message = new String(data).trim();
  println("Empfangen: '" + message + "' von " + ip + ":" + port);

  String cleaned = message.replace(";", "").trim();
  try {
    currentTick = Integer.parseInt(cleaned);
  }
  catch (NumberFormatException e) {
    println("Fehler beim Parsen: " + e.getMessage());
  }
}

void loadSegmentsFromJson(String filename) {
  JSONArray arr = loadJSONArray(filename);
  if (arr == null) {
    println("Fehler: Keine segments.json gefunden!");
    segments = new Segment[0];
    return;
  }

  segments = new Segment[arr.size()];
  int cumulativeStartMeasure = 0;

  for (int i = 0; i < arr.size(); i++) {
    JSONObject obj = arr.getJSONObject(i);

    int measures       = obj.getInt("measures", 1);
    String timeSigStr  = obj.getString("timeSignature", "4/4");
    String tonart      = obj.getString("tonart", "C-Dur");
    int tempo          = obj.getInt("tempo", 120);
    int dissonanz      = obj.getInt("dissonanz", 0);
    int komplexitaet   = obj.getInt("komplexitaet", 0);
    int intensitaet    = obj.getInt("intensitaet", 0);

    String gregorRole  = obj.getString("gregorRole", "none");
    String aliRole     = obj.getString("aliRole", "none");
    String frankRole   = obj.getString("frankRole", "none");

    int beatsPerMeasure = parseTimeSignatureBeats(timeSigStr);
    int segmentLengthInTicks = measures * beatsPerMeasure * TICKS_PER_BEAT;

    int startTick;
    if (i == 0) {
      startTick = 0;
    } else {
      startTick = segments[i-1].endTick;
    }

    int endTick = startTick + segmentLengthInTicks;

    Segment s = new Segment(
      startTick, endTick,
      measures, timeSigStr,
      tonart, tempo,
      dissonanz, komplexitaet, intensitaet,
      gregorRole, aliRole, frankRole,
      cumulativeStartMeasure
      );
    segments[i] = s;

    cumulativeStartMeasure += measures;
  }
}

Segment getCurrentSegment(int tick) {
  for (Segment s : segments) {
    if (tick >= s.startTick && tick < s.endTick) {
      return s;
    }
  }
  return null;
}

int parseTimeSignatureBeats(String ts) {
  String[] parts = split(ts, '/');
  if (parts.length == 2) {
    try {
      return Integer.parseInt(parts[0]);
    }
    catch (NumberFormatException e) {
      println("Fehler in Taktart: " + ts);
    }
  }
  return 4; // fallback
}

float computeElapsedTimeSec(int upToTick) {
  float totalSec = 0;
  for (Segment s : segments) {
    int segStart = s.startTick;
    int segEnd   = s.endTick;

    // Ticks pro Sekunde = tempo * TICKS_PER_BEAT / 60
    float ticksPerSec = (s.tempo * TICKS_PER_BEAT) / 60.0;

    if (upToTick >= segEnd) {
      // ganzes Segment
      int segLength = segEnd - segStart;
      float segTime = segLength / ticksPerSec;
      totalSec += segTime;
    } else if (upToTick >= segStart && upToTick < segEnd) {
      // Teil-Abschnitt
      int partialLen = upToTick - segStart;
      float partTime = partialLen / ticksPerSec;
      totalSec += partTime;
      break;
    } else if (upToTick < segStart) {
      // noch gar nicht in diesem Segment
      break;
    }
  }
  return totalSec;
}

// -----------------------------------------------------------------------------
// SEGMENT-KLASSE

class Segment {
  int startTick;
  int endTick;

  int measures;
  String timeSignature;

  String tonart;
  int tempo;
  int dissonanz;
  int komplexitaet;
  int intensitaet;

  String gregorRole;
  String aliRole;
  String frankRole;

  int absoluteStartMeasure;

  Segment(
    int startTick, int endTick,
    int measures,
    String timeSignature,
    String tonart,
    int tempo,
    int dissonanz,
    int komplexitaet,
    int intensitaet,
    String gregorRole,
    String aliRole,
    String frankRole,
    int absoluteStartMeasure
    ) {
    this.startTick     = startTick;
    this.endTick       = endTick;
    this.measures      = measures;
    this.timeSignature = timeSignature;

    this.tonart        = tonart;
    this.tempo         = tempo;
    this.dissonanz     = dissonanz;
    this.komplexitaet  = komplexitaet;
    this.intensitaet   = intensitaet;

    this.gregorRole    = gregorRole;
    this.aliRole       = aliRole;
    this.frankRole     = frankRole;

    this.absoluteStartMeasure = absoluteStartMeasure;
  }
}
