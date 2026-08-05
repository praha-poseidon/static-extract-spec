import React, { Component } from "react";
import * as client from "./client";

export class UserPanel extends Component {
  render() {
    return <button>{client.label}</button>;
  }
}
