// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

struct Bigint {
    uint256[] limbs;
}

library BigIntLib {
    function fromUint(uint256 x) internal pure returns (Bigint memory r) {
        r.limbs = new uint256[](1);
        r.limbs[0] = x;
    }

    function add(Bigint memory a, Bigint memory b) internal pure returns (Bigint memory r) {
        r.limbs = new uint256[](max(a.limbs.length, b.limbs.length));
        uint256 carry = 0;
        uint256 len = r.limbs.length;
        for (uint256 i = 0; i < len; ++i) {
            uint256 limbA = limb(a, i);
            uint256 limbB = limb(b, i);
            unchecked {
                r.limbs[i] = limbA + limbB + carry;

                if (limbA + limbB < limbA || (limbA + limbB == type(uint256).max && carry > 0)) carry = 1;
                else carry = 0;
            }
        }
        if (carry > 0) {
            // too bad, we have to add a limb
            uint256[] memory newLimbs = new uint256[](r.limbs.length + 1);
            uint256 i;
            len = r.limbs.length;
            for (i = 0; i < len; ++i) {
                newLimbs[i] = r.limbs[i];
            }
            newLimbs[i] = carry;
            r.limbs = newLimbs;
        }
    }

    function limb(Bigint memory a, uint256 index) internal pure returns (uint256 res) {
        return index < a.limbs.length ? a.limbs[index] : 0;
    }

    function max(uint256 a, uint256 b) private pure returns (uint256 res) {
        return a > b ? a : b;
    }
}
