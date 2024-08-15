// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Book {
    string public title;
    string public author;

    constructor(string memory _title, string memory _author) {
        require(bytes(_title).length > 0, "Title cannot be empty");
        require(bytes(_author).length > 0, "Author cannot be empty");
        title = _title;
        author = _author;
    }

    function getDetails() public view returns (string memory, string memory) {
        return (title, author);
    }
}

contract Library {
    Book[] public books;
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function addBook(string memory _title, string memory _author)
        public
        onlyOwner
    {
        require(bytes(_title).length > 0, "Title cannot be empty");
        require(bytes(_author).length > 0, "Author cannot be empty");

        Book newBook = new Book(_title, _author);
        books.push(newBook);
    }

    function getBookDetails(uint256 index)
        public
        view
        returns (string memory, string memory)
    {
        require(index < books.length, "Invalid index");
        Book book = books[index];
        return book.getDetails();
    }

    function totalBooks() public view returns (uint256) {
        return books.length;
    }
}
