// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract ContactManager {
    struct Contact {
        string name;
        string phone;
        string email;
    }

    mapping(address => Contact[]) private contacts;

    event ContactAdded(address indexed owner, string name);
    event ContactUpdated(address indexed owner, string name);
    event ContactDeleted(address indexed owner, string name);

    /* ----------------------
       Public / External API
       ---------------------- */

    /// @notice Add a contact for msg.sender. Name and phone must be non-empty.
    ///         Duplicate names (case-insensitive) are ignored.
    function addContact(
        string calldata name,
        string calldata phone,
        string calldata email
    ) external {
        require(bytes(name).length > 0, "Name cannot be empty");
        require(bytes(phone).length > 0, "Phone cannot be empty");

        // Check duplicate (case-insensitive)
        string memory lowered = toLower(name);
        Contact[] storage userContacts = contacts[msg.sender];
        for (uint i = 0; i < userContacts.length; i++) {
            if (
                keccak256(bytes(toLower(userContacts[i].name))) ==
                keccak256(bytes(lowered))
            ) {
                // duplicate found, do nothing (could also revert)
                return;
            }
        }

        userContacts.push(Contact({name: name, phone: phone, email: email}));
        emit ContactAdded(msg.sender, name);
    }

    /// @notice Return all contacts for caller
    function getContacts() external view returns (Contact[] memory) {
        return contacts[msg.sender];
    }

    /// @notice Search contact by name (case-insensitive). Returns (contact, found)
    function searchByName(
        string calldata name
    ) external view returns (Contact memory, bool) {
        Contact[] storage userContacts = contacts[msg.sender];
        bytes32 targetHash = keccak256(bytes(toLower(name)));
        for (uint i = 0; i < userContacts.length; i++) {
            if (keccak256(bytes(toLower(userContacts[i].name))) == targetHash) {
                return (userContacts[i], true);
            }
        }
        // return empty struct and false if not found
        Contact memory emptyContact;
        return (emptyContact, false);
    }

    /// @notice Update contact fields by name (case-insensitive). Only non-empty new fields are applied.
    function updateContact(
        string calldata name,
        string calldata newPhone,
        string calldata newEmail
    ) external {
        Contact[] storage userContacts = contacts[msg.sender];
        bytes32 targetHash = keccak256(bytes(toLower(name)));
        bool found = false;
        for (uint i = 0; i < userContacts.length; i++) {
            if (keccak256(bytes(toLower(userContacts[i].name))) == targetHash) {
                // modify in storage directly
                if (bytes(newPhone).length > 0) {
                    userContacts[i].phone = newPhone;
                }
                if (bytes(newEmail).length > 0) {
                    userContacts[i].email = newEmail;
                }
                emit ContactUpdated(msg.sender, userContacts[i].name);
                found = true;
                break;
            }
        }
        require(found, "Contact not found");
    }

    /// @notice Delete a contact by name (case-insensitive). Uses swap & pop.
    function deleteContact(string calldata name) external {
        Contact[] storage userContacts = contacts[msg.sender];
        bytes32 targetHash = keccak256(bytes(toLower(name)));
        uint index = type(uint).max;
        for (uint i = 0; i < userContacts.length; i++) {
            if (keccak256(bytes(toLower(userContacts[i].name))) == targetHash) {
                index = i;
                break;
            }
        }
        require(index != type(uint).max, "Contact not found");

        string memory deletedName = userContacts[index].name;

        // swap with last and pop
        uint last = userContacts.length - 1;
        if (index != last) {
            userContacts[index] = userContacts[last];
        }
        userContacts.pop();

        emit ContactDeleted(msg.sender, deletedName);
    }

    /* ----------------------
       Helper utilities
       ---------------------- */

    /// @notice Convert ASCII A-Z to a-z; leaves other bytes unchanged.
    ///         Works for basic ASCII letters; not a full Unicode lowercase.
    function toLower(string memory str) public pure returns (string memory) {
        bytes memory b = bytes(str);
        for (uint i = 0; i < b.length; i++) {
            // 'A' = 0x41, 'Z' = 0x5A; convert to 'a'..'z' by adding 0x20
            if (b[i] >= 0x41 && b[i] <= 0x5A) {
                b[i] = bytes1(uint8(b[i]) + 32);
            }
        }
        return string(b);
    }
}
