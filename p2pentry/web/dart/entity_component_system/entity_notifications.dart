part of game;

class EntityNotifications {
    static int nfcounter = 0;
    // CONTEXT Notifications
    static int NF_POSITION_UPDATE            = ++nfcounter;
    static int NF_ROTATION_UPDATE            = ++nfcounter;
    static int NF_PLAYER_WALK_FORWARDS       = ++nfcounter;
    static int NF_PLAYER_WALK_BACKWARDS      = ++nfcounter;
    static int NF_PLAYER_WALK_RIGHT          = ++nfcounter;
    static int NF_PLAYER_WALK_LEFT           = ++nfcounter;
    static int NF_PLAYER_WALK_JUMP           = ++nfcounter;
    static int NF_PLAYER_FLY_UP              = ++nfcounter;
    static int NF_PLAYER_FLY_DOWN            = ++nfcounter;
    static int NF_PLAYER_RESET               = ++nfcounter;
    static int NF_PLAYER_CAMERA_UPDATE       = ++nfcounter;
    static int NF_PLAYER_CAMERA_ZOOM_FACTOR_UPDATE = ++nfcounter;
    static int NF_PLAYER_CAMERA_POSITION_UPDATE = ++nfcounter;
    static int NF_PLAYER_MOUSE_MOVE          = ++nfcounter;
    static int NF_PLAYER_PHYSICS_TICK        = ++nfcounter;
    static int NF_PLAYER_CAMERA_RAIL         = ++nfcounter;
    static int NF_SET_CAMERA_ROTATION        = ++nfcounter;

    static int gfcounter = 0;
    // GET Notifications
    static int GF_ZOOM_FACTOR                = ++gfcounter;
    static int GF_KEYBINDINGS                = ++gfcounter;
    static int GF_CAMERA                     = ++gfcounter;
    static int GF_CAMERA_ROTATION            = ++gfcounter;
    static int GF_GEOMETRY                   = ++gfcounter;
    static int GF_MATERIAL                   = ++gfcounter;
}