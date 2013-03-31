class MFWHumanPawn extends KFHumanPawn;

var Frag fragWeapons[2];
var int currFragIndex;

replication {
    reliable if (Role == ROLE_Authority)
        fragWeapons, currFragIndex;
}

function Frag getCurrentFrag() {
    return fragWeapons[currFragIndex];
}

function AddDefaultInventory() {
    local Inventory inv;
    local int index;

    super.AddDefaultInventory();
    for(inv= Inventory; inv != none; inv= inv.Inventory) {
        if (FlameFrag(inv) != none) {
            fragWeapons[index]= FlameFrag(inv);
            currFragIndex= index;
            index++;
        } else if (MedicFrag(inv) != none) {
            fragWeapons[index]= MedicFrag(inv);
            index++;
        }
    }
}

exec function switchGrenade() {
    local int nextFragIndex;

    nextFragIndex= currFragIndex;
    do {
        nextFragIndex++;
        if (nextFragIndex >= ArrayCount(fragWeapons)) {
            nextFragIndex= 0;
        }
    } until(fragWeapons[nextFragIndex] != none);
    currFragIndex= nextFragIndex;
}

function ThrowGrenade() {
    if (fragWeapons[currFragIndex] != none && fragWeapons[currFragIndex].HasAmmo() && !bThrowingNade) {
        if (KFWeapon(Weapon) == none || Weapon.GetFireMode(0).NextFireTime - Level.TimeSeconds > 0.1 ||
                 (KFWeapon(Weapon).bIsReloading && !KFWeapon(Weapon).InterruptReload())) {
                return;
        }

        //TODO: cache this without setting SecItem yet
        //SecondaryItem = aFrag;
        KFWeapon(Weapon).ClientGrenadeState = GN_TempDown;
        Weapon.PutDown();
    }
}

function WeaponDown() {
    if (fragWeapons[currFragIndex]!=none && fragWeapons[currFragIndex].HasAmmo()) {
        SecondaryItem = fragWeapons[currFragIndex];
        fragWeapons[currFragIndex].StartThrow();
    }
}


defaultproperties {
    RequiredEquipment(2)="MultiFragWeapon.FlameFrag"
    RequiredEquipment(5)="MultiFragWeapon.MedicFrag"
}
