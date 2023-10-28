array<string> strSaveIds;
array<array<double>> dSaveParams =
{
	/*0 - Enabled/Disabled; 1 - TraceSize; 2 - TraceTime; 3 - ColorRed, 4 - ColorGreen;
	5 - ColorBlue; 6 - HitColorRed; 7 - HitColorGreen; 8 - HitColorBlue*/
	
	//{ 0, 3, 0.5, 125, 125, 125, 125, 0, 0 },
	//{ 1, 5, 0.7, 255, 255, 255, 255, 125, 125 }
};

void MapInit() {
	g_Game.PrecacheModel("scripts/plugins/BulletTracer/laserbeam.spr");
}

void PluginInit()
{
	g_Module.ScriptInfo.SetAuthor("kek");
	g_Module.ScriptInfo.SetContactInfo("No Information");
	
	g_Hooks.RegisterHook(Hooks::Player::ClientSay, @ClientSay);
	g_Hooks.RegisterHook(Hooks::Player::ClientPutInServer, @ClientPutInServer);
	
	g_Hooks.RegisterHook(Hooks::Weapon::WeaponPrimaryAttack, @WeaponPrimaryAttack);
}

array<string> WeaponFilter()
{
	array<string> strWeapons = 
	{
		"weapon_crowbar",
		"weapon_pipewrench",
		"weapon_medkit",
		"weapon_grapple",
		"weapon_rpg",
		"weapon_gauss",
		"weapon_egon",
		"weapon_hornetgun",
		"weapon_handgrenade",
		"weapon_satchel",
		"weapon_tripmine",
		"weapon_snark",
		"weapon_sporelauncher",
		"weapon_displacer"
	};
	
	return strWeapons;
}

class cColor
{
	cColor() { };
	cColor(int iColorRed, int iColorGreen, int iColorBlue)
	{
		iRed = iColorRed;
		iGreen = iColorGreen;
		iBlue = iColorBlue;
	};

	int iRed;
	int iGreen;
	int iBlue;
};

bool IsNaN(string strValue)
{
	int iPointCount = 0;

	for (uint i = 0; i < strValue.Length(); i++)
	{
		if (i == 0 && strValue[i] == '-')
			continue;
			
		if (strValue[i] == '.')
		{
			iPointCount++;
		
			if (iPointCount < 2)
				continue;
		}
	
		if (!isdigit(strValue[i]))
			return true;
	}
	
	return false;
}

void DrawBulletTrace(CBasePlayer@ pPlayer, CBasePlayerWeapon@ pWeapon, cColor cTraceColor, cColor cTraceHitColor, int iTraceSize, double dTraceTime, bool bFilterWeapons)
{
	CBeam@ pBeam = g_EntityFuncs.CreateBeam("scripts/plugins/BulletTracer/laserbeam.spr", iTraceSize);

    Vector vVecAngles = pPlayer.pev.v_angle;
    Vector vVecEyePos = pPlayer.EyePosition();

    Vector vVecDirection, vVecIntermediate;
    g_EngineFuncs.AngleVectors(vVecAngles, vVecDirection, vVecIntermediate, vVecIntermediate);

    Vector vVecEndPos = (vVecEyePos + (vVecDirection * Math.INT32_MAX));
	
	TraceResult trResult;
	g_Utility.TraceLine(vVecEyePos, vVecEndPos, dont_ignore_monsters, pPlayer.edict(), trResult);
	
	if (bFilterWeapons)
	{
		array<string> strGetWeapons = WeaponFilter();
		int iArrayLength = strGetWeapons.length();
	
		for (int i = 0; i < iArrayLength; i++)
		{
			if (pWeapon.pev.classname == strGetWeapons[i]
				|| pWeapon.m_bFireOnEmpty)
					return;
		}
	}
	
	if (trResult.pHit.vars.health > 0)
		pBeam.SetColor(cTraceHitColor.iRed, cTraceHitColor.iGreen, cTraceHitColor.iBlue);
	else
		pBeam.SetColor(cTraceColor.iRed, cTraceColor.iGreen, cTraceColor.iBlue);
	
    pBeam.SetStartPos(vVecEyePos);
    pBeam.SetEndPos(trResult.vecEndPos);
	pBeam.LiveForTime(dTraceTime);
}

HookReturnCode WeaponPrimaryAttack(CBasePlayer@ pPlayer, CBasePlayerWeapon@ pWeapon)
{
	int iPlayerIndex = 0;
	int iIdsLength = strSaveIds.length();
	
	string strId = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());

	for (int i = 0; i < iIdsLength; i++)
	{
		if (strId == strSaveIds[i])
		{
			iPlayerIndex = i;
			break;
		}
	}
	
	if (dSaveParams.length() > 0)
	{
		if (dSaveParams[iPlayerIndex][0] == 1)
		{
			cColor cTraceColor(int(dSaveParams[iPlayerIndex][3]), int(dSaveParams[iPlayerIndex][4]), int(dSaveParams[iPlayerIndex][5]));
			cColor cTraceHitColor(int(dSaveParams[iPlayerIndex][6]), int(dSaveParams[iPlayerIndex][7]), int(dSaveParams[iPlayerIndex][8]));
			
			DrawBulletTrace(pPlayer, pWeapon, cTraceColor, cTraceHitColor, int(dSaveParams[iPlayerIndex][1]), dSaveParams[iPlayerIndex][2], true);
		}
	}
	
    return HOOK_CONTINUE;
}

HookReturnCode ClientPutInServer(CBasePlayer@ pPlayer)
{
	bool bSkipPlayer = false;

	int iIdsLength = strSaveIds.length();
	int iParamsLength = dSaveParams.length();
	
	string strId = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());
	
	for (int i = 0; i < iIdsLength; i++)
	{
		if (strId == strSaveIds[i])
		{
			bSkipPlayer = true;	
			break;
		}
	}

	if ((iParamsLength <= 0 && iIdsLength <= 0) || !bSkipPlayer)
	{
		dSaveParams.insertAt(iParamsLength, array<double> = { 1, 3, 0.5, 125, 125, 125, 125, 0, 0 });	
		strSaveIds.insertAt(iIdsLength, strId);
	}
	
	return HOOK_CONTINUE;
}

HookReturnCode ClientSay(SayParameters@ pSayParam)
{
	int iPlayerIndex = -1;
	bool bSkipPlayer = false;

	int iIdsLength = strSaveIds.length();
	int iParamsLength = dSaveParams.length();

	string strMsg = pSayParam.GetCommand();
	int iArgs = pSayParam.GetArguments().ArgC();
	
	CBasePlayer@ pPlayer = pSayParam.GetPlayer();
	string strId = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());
	
	for (int i = 0; i < iIdsLength; i++)
	{
		if (strId == strSaveIds[i])
		{
			iPlayerIndex = i;
			bSkipPlayer = true;
			
			break;
		}
	}
	
	if ((iParamsLength <= 0 && iIdsLength <= 0) || !bSkipPlayer)
	{
		dSaveParams.insertAt(iParamsLength, array<double> = { 1, 3, 0.5, 125, 125, 125, 125, 0, 0 });	
		strSaveIds.insertAt(iIdsLength, strId);
		
		iIdsLength = strSaveIds.length();
		iParamsLength = dSaveParams.length();
		
		ClientSay(pSayParam);
		return HOOK_CONTINUE;
	}
	
	if (iPlayerIndex != -1)
	{
		bool bError = false;
		array<string> strCommands = 
		{
			".btc", "/btc", "!btc",
			".bthc", "/bthc", "!bthc",
			".bte", "/bte", "!bte",
			".bts", "/bts", "!bts",
			".btt", "/btt", "!btt"
		};
		
		array<string> strDescriptions =
		{
			"[BTInfo]: Usage: .btc//btc/!btc <red> <green> <blue>. Example: !btc 125 125 125\n",
			"[BTInfo]: Usage: .bthc//bthc/!bthc <red> <green> <blue>. Example: !bthc 125 0 0\n",
			"[BTInfo]: Usage: .bte//bte/!bte <state>. Example: !bte 1\n",
			"[BTInfo]: Usage: .bts//bts/!bts <size>. Example: !bts 3\n",
			"[BTInfo]: Usage: .btt//btt/!btt <time>. Example: !btt 0.5\n",
		};
		
		//btr and info
		if (iArgs == 1)
		{
			int iNum = 0;
		
			for (uint i = 0; i < strCommands.length(); i++)
			{
				if (pSayParam.GetArguments().Arg(0) == strCommands[i])
				{
					if (i > 0 && i < 3)
						iNum = 0;
						
					if (i > 3 && i < 6)
						iNum = 1;
						
					if (i > 6 && i < 9)
						iNum = 2;
						
					if (i > 9 && i < 12)
						iNum = 3;
						
					if (i > 12 && i < 15)
						iNum = 4;
				
					g_PlayerFuncs.SayText(pPlayer, strDescriptions[iNum]);
					
					pSayParam.ShouldHide = true;
					return HOOK_HANDLED;
				}
			}
		
			if (pSayParam.GetArguments().Arg(0) == ".btr"
				|| pSayParam.GetArguments().Arg(0) == "/btr"
				|| pSayParam.GetArguments().Arg(0) == "!btr")
			{
				dSaveParams[iPlayerIndex][0] = 1;
				dSaveParams[iPlayerIndex][1] = 3;
				dSaveParams[iPlayerIndex][2] = 0.5;
				dSaveParams[iPlayerIndex][3] = 125;
				dSaveParams[iPlayerIndex][4] = 125;
				dSaveParams[iPlayerIndex][5] = 125;
				dSaveParams[iPlayerIndex][6] = 125;
				dSaveParams[iPlayerIndex][7] = 0;
				dSaveParams[iPlayerIndex][8] = 0;
				
				g_PlayerFuncs.SayText(pPlayer, "[BTSuccess]: All beam settings have been reset to their default values.\n");
				
				pSayParam.ShouldHide = true;
				return HOOK_HANDLED;
			}
		}
		
		//bte, bts, btt
		if (iArgs == 2)
		{
			if (pSayParam.GetArguments().Arg(0) == ".bte"
				|| pSayParam.GetArguments().Arg(0) == "/bte"
				|| pSayParam.GetArguments().Arg(0) == "!bte")
			{
				string strState = pSayParam.GetArguments().Arg(1);
				
				if (!bError && IsNaN(strState))
				{
					g_PlayerFuncs.SayText(pPlayer, "[BTError]: The argument is not a number!\n");
					bError = true;
				}
					
				if (!bError)
				{
					double dEnabled = int(atod(strState));
				
					if (dEnabled > 1.0)
						dEnabled = 1.0;
					
					if (dEnabled < 0.0)
						dEnabled = 0.0;
				
					dSaveParams[iPlayerIndex][0] = dEnabled;					
					g_PlayerFuncs.SayText(pPlayer, (dEnabled == 1
						? "[BTSuccess]: The bullet trace function was enabled!\n" 
						: "[BTSuccess]: The bullet trace function was disabled!\n"));
				}
				
				pSayParam.ShouldHide = true;
				return HOOK_HANDLED;
			}
			
			if (pSayParam.GetArguments().Arg(0) == ".bts"
				|| pSayParam.GetArguments().Arg(0) == "/bts"
				|| pSayParam.GetArguments().Arg(0) == "!bts")
			{
				double dSize = 0.0;
				string strSize = pSayParam.GetArguments().Arg(1);
				
				if (!bError && IsNaN(strSize))
				{
					g_PlayerFuncs.SayText(pPlayer, "[BTError]: The argument is not a number!\n");
					bError = true;
				}
				
				if (!bError)
					dSize = int(atod(strSize));
				
				if (!bError)
				{
					if (dSize <= 0 || dSize > 5.0)
					{
						g_PlayerFuncs.SayText(pPlayer, "[BTError]: The beam size should be between 1 and 5!\n");
						bError = true;
					}
				}
				
				if (!bError)
				{
					dSaveParams[iPlayerIndex][1] = dSize;
					g_PlayerFuncs.SayText(pPlayer, "[BTSuccess]: The beam size has been successfully changed!\n");
				}
				
				pSayParam.ShouldHide = true;
				return HOOK_HANDLED;
			}
			
			if (pSayParam.GetArguments().Arg(0) == ".btt"
				|| pSayParam.GetArguments().Arg(0) == "/btt"
				|| pSayParam.GetArguments().Arg(0) == "!btt")
			{
				double dTime = 0.0;
				string strTime = pSayParam.GetArguments().Arg(1);
				
				if (!bError && IsNaN(strTime))
				{
					g_PlayerFuncs.SayText(pPlayer, "[BTError]: The argument is not a number!\n");
					bError = true;
				}
				
				if (!bError)
					dTime = atod(strTime);
					
				if (!bError)
				{
					if (dTime < 0.1 || dTime > 1.0)
					{
						g_PlayerFuncs.SayText(pPlayer, "[BTError]: The beam display time should be between 0.1 and 1!\n");
						bError = true;
					}
				}
				
				if (!bError)
				{
					dSaveParams[iPlayerIndex][2] = dTime;
					g_PlayerFuncs.SayText(pPlayer, "[BTSuccess]: The beam display time has been successfully changed!\n");
				}
				
				pSayParam.ShouldHide = true;
				return HOOK_HANDLED;
			}
		}
	
		//btc, bthc
		if (iArgs == 4)
		{
			string strRed = pSayParam.GetArguments().Arg(1);
			string strGreen = pSayParam.GetArguments().Arg(2);
			string strBlue = pSayParam.GetArguments().Arg(3);
			
			double dRed = 0.0;
			double dGreen = 0.0;
			double dBlue = 0.0;
			
			if (!bError && (IsNaN(strRed) 
				|| IsNaN(strGreen) 
				|| IsNaN(strBlue)))
			{
				g_PlayerFuncs.SayText(pPlayer, "[BTError]: Сan't change the color of the trace. One of the arguments is incorrect!\n");
				bError = true;
			}
			
			if (!bError && (strRed.Length() > 3 
				|| strGreen.Length() > 3
				|| strBlue.Length() > 3))
			{
				g_PlayerFuncs.SayText(pPlayer, "[BTError]: One of the arguments is too large to convert!\n");
				bError = true;
			}
			
			if (!bError)
			{
				dRed = atod(strRed);
				dGreen = atod(strGreen);
				dBlue = atod(strBlue);
			}
			
			if (!bError && (dRed < 0 || dRed > 255
				|| dGreen < 0 || dGreen > 255
				|| dBlue < 0 || dBlue > 255))
			{
				g_PlayerFuncs.SayText(pPlayer, "[BTError]: The color value must be between 0 and 255!\n");
				bError = true;
			}
			
			if (!bError)
			{
				if (pSayParam.GetArguments().Arg(0) == ".btc"
					|| pSayParam.GetArguments().Arg(0) == "/btc"
					|| pSayParam.GetArguments().Arg(0) == "!btc")
				{
					dSaveParams[iPlayerIndex][3] = dRed;
					dSaveParams[iPlayerIndex][4] = dGreen;
					dSaveParams[iPlayerIndex][5] = dBlue;
					
					g_PlayerFuncs.SayText(pPlayer, "[BTSuccess]: The trace color has been successfully changed!\n");
				}
				
				if (pSayParam.GetArguments().Arg(0) == ".bthc"
					|| pSayParam.GetArguments().Arg(0) == "/bthc"
					|| pSayParam.GetArguments().Arg(0) == "!bthc")
				{
					dSaveParams[iPlayerIndex][6] = dRed;
					dSaveParams[iPlayerIndex][7] = dGreen;
					dSaveParams[iPlayerIndex][8] = dBlue;
					
					g_PlayerFuncs.SayText(pPlayer, "[BTSuccess]: The trace hit color has been successfully changed!\n");
				}
			}
			
			pSayParam.ShouldHide = true;
			return HOOK_HANDLED;
		}
	}
	
	return HOOK_CONTINUE;
}