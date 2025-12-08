pragma solidity ^0.8.0;

contract StringUtilities {
    mapping(address => string[]) private notes;

    function addNote(string memory note) external {
        require(bytes(note).length > 0, "Cannot add empty note");
        notes[msg.sender].push(note);
    }

    function getAllNotes() external view returns (string[] memory) {
        return notes[msg.sender];
    }

    function concatenateNotes() external view returns (string memory) {
        string memory allNotes = "";
        for (uint i = 0; i < notes[msg.sender].length; i++) {
            allNotes = string(
                abi.encodePacked(
                    allNotes,
                    notes[msg.sender][i],
                    i < notes[msg.sender].length - 1 ? ", " : ""
                )
            );
        }
        return allNotes;
    }

    // Optional: trimming function (remove leading/trailing spaces)
    function trim(string memory str) public pure returns (string memory) {
        bytes memory strBytes = bytes(str);
        uint start = 0;
        uint end = strBytes.length;

        // find first non-space character
        while (start < end && strBytes[start] == 0x20) {
            start++;
        }

        // find last non-space character
        while (end > start && strBytes[end - 1] == 0x20) {
            end--;
        }

        bytes memory result = new bytes(end - start);
        for (uint i = start; i < end; i++) {
            result[i - start] = strBytes[i];
        }

        return string(result);
    }
}
