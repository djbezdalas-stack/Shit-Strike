#include <amxmodx>
#include <fakemeta>
#include <engine>

new Float:g_fCheckpointOrigin[33][3];
new Float:g_fCheckpointAngles[33][3];
new bool:g_bHasCheckpoint[33];

public plugin_init()
{
    register_plugin("KZ Checkpoint System", "1.1", "YourName");

    // Commands
    register_clcmd("say /cp", "cmdSetCheckpoint");
    register_clcmd("say /checkpoint", "cmdSetCheckpoint");

    register_clcmd("say /tp", "cmdTeleportCheckpoint");
    register_clcmd("say /gocheck", "cmdTeleportCheckpoint");

    register_clcmd("say /delcp", "cmdDeleteCheckpoint");
    register_clcmd("say /undo", "cmdDeleteCheckpoint");

    // Hook think for fall detection
    register_forward(FM_PlayerPreThink, "fw_PlayerPreThink");
}

public client_disconnect(id)
{
    g_bHasCheckpoint[id] = false;
}

public cmdSetCheckpoint(id)
{
    if (!is_user_alive(id)) return PLUGIN_HANDLED;

    pev(id, pev_origin, g_fCheckpointOrigin[id]);
    pev(id, pev_v_angle, g_fCheckpointAngles[id]);
    g_bHasCheckpoint[id] = true;

    client_print(id, print_chat, "[CP] Checkpoint saved!");
    return PLUGIN_HANDLED;
}

public cmdTeleportCheckpoint(id)
{
    if (!is_user_alive(id) || !g_bHasCheckpoint[id]) return PLUGIN_HANDLED;

    engfunc(EngFunc_SetOrigin, id, g_fCheckpointOrigin[id]);
    set_pev(id, pev_angles, g_fCheckpointAngles[id]);
    set_pev(id, pev_fixangle, 1);

    client_print(id, print_chat, "[CP] Teleported to checkpoint!");
    return PLUGIN_HANDLED;
}

public cmdDeleteCheckpoint(id)
{
    if (!g_bHasCheckpoint[id]) {
        client_print(id, print_chat, "[CP] You don't have a checkpoint set!");
        return PLUGIN_HANDLED;
    }

    g_bHasCheckpoint[id] = false;
    client_print(id, print_chat, "[CP] Your checkpoint has been deleted!");
    return PLUGIN_HANDLED;
}

public fw_PlayerPreThink(id)
{
    if (!is_user_alive(id) || !g_bHasCheckpoint[id]) return FMRES_IGNORED;

    new flags = pev(id, pev_flags);
    if (flags & FL_ONGROUND)
    {
        new Float:origin[3];
        pev(id, pev_origin, origin);

        // If player is 30 units lower than checkpoint → teleport
        if (origin[2] < g_fCheckpointOrigin[id][2] - 30.0)
        {
            cmdTeleportCheckpoint(id);
        }
    }

    return FMRES_IGNORED;
}